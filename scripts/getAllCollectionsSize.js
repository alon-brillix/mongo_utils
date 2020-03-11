function getSize(limit, filter) {
	var colls = db.getCollectionNames();
	var collection, stats, totalStorageSize;
	var stopAfter = limit;
	if (typeof filter === 'string') {
		colls = colls.filter(c=>c.match(filter));
	}
	if ((stopAfter || 0) === 0) {
		stopAfter = colls.length;
	}
	print('collection,size,totalStorageSize,count,isSharded')
	for (var i = 0; i < stopAfter; i++) {
		collection = colls[i];
		stats = db[collection].stats();
		totalStorageSize = stats.storageSize+stats.totalIndexSize;
		print(`${collection},${stats.size},${totalStorageSize},${stats.count},${stats.sharded}`);
	}
}

getSize(0, '^activities_by_customer')

