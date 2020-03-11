#!/bin/bash
[ -f ~/.mongo.env ] && . ~/.mongo.env

getDir() {
	local SOURCE="${BASH_SOURCE[0]}"
	local DIR
	while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
	  SOURCE="$(readlink "$SOURCE")"
	  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	done
	DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
	echo ${DIR}
}
DIR=$(getDir)

usage() {
	local str
	read -d '' str <<-EOF
		Usage $(basename $0) [OPTION]...
		Use this tool to monitor the count of a collection.
		The tool will draw an ongoing graph with icrease(red) and decrease(green) of the count

		OPTIONS
		-h|--help			help - print this help page
		-c|--collection	collection - which collection to generate the DDL for
		-d|--database		database - where the collection resides (default to [${MONGO_DB}])
		-p|--pretty			Add prettyfing comments
	EOF

	echo -e "${str}\n"
	exit
}

RED() {
	local text=$*
	echo -e "\e[31m${text}\e[0m"
}
GREEN() {
	local text=$*
	echo -e "\e[32m${text}\e[0m"
}



getData() {
	mongo --quiet --host ${MONGOS} -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase admin ${MONGO_DB} --eval "load('${DIR}/../scripts/getDDL.js'); getDDL('${collection}', ${pretty})"
}

pretty=false
while getopts ":hpc:d:-:" opt; do
	case ${opt} in
		c)
			collection=${OPTARG}
			;;
		d)
			MONGO_DB=${OPTARG}
			;;
		p)
			pretty=true
			;;
		-)
			OPT=$(echo ${OPTARG}|cut -d'=' -f1)
			VAL=$(echo ${OPTARG}|cut -d'=' -f2)
			case ${OPT} in
				pretty)
					pretty=true
					;;
				collection)
					collection=${VAL}
					;;
				database)
					MONGO_DB=${VAL}
					;;
			esac
			;;
		h)
			usage
			;;
		\?)
			echo "Invalid option: -${OPTARG}" >&2
			usage
			;;
		esac
done

if [[ ${collection} == "" ]];then
	echo -e "$(RED Mandatory argument [collection] is missing!)"
	usage
fi
DIR=$(getDir)
getData
