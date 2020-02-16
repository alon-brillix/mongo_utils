function getDDL(collection, pretty) {
	var database = db.getName();
	var indexes = db[collection].getIndexes();
	var shardSpec = db.getSiblingDB('config').collections.findOne({_id: `${database}.${collection}`});
	var DDL = {};
	var indexOptions;
	DDL.createCollection = `db.createCollection("${collection}")`;
	if (shardSpec !== null) {
		DDL.shard = {
			shardCollection: `${database}.${collection}`,
			key: shardSpec.key,
			unique: shardSpec.unique,
			numInitialChunks: shardSpec.numInitialChunks
		};
		(DDL.shard.numInitialChunks === null) && delete DDL.shard.numInitialChunks
	}
	DDL.indexes = [];
	for (var i = 0; i < indexes.length; i++){
		if (indexes[i].name !== "_id_") {
			indexOptions = {};
			for (var key of Object.keys(indexes[i])){
				if (["v", "key", "ns"].indexOf(key) === -1){
					indexOptions[key] = indexes[i][key];
				}
			}
			DDL.indexes.push(`db.${collection}.createIndex(${JSON.stringify(indexes[i].key)}, ${JSON.stringify(indexOptions)})`);
		}
	}
	var output = "";
	if (pretty === true) output += `/*** ${database}.${collection} ***/\n`
	output += `${DDL.createCollection};\n`
	if (DDL.shard !== undefined) output += `db.adminCommand(${JSON.stringify(DDL.shard)});\n`
	for (var i = 0; i < DDL.indexes.length; i++){
		output += `${DDL.indexes[i]};\n`
	}
	if (pretty === true) output += `\n/*-- ${database}.${collection} --*/`
	return output;
}
