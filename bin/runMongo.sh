#!/bin/bash
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
[ -f ~/.mongo.env ] && . ~/.mongo.env
DIR="$(getDir)/.."

script=$1
host=${2:-${MONGOS}}
echo "Running ${script} on ${host}"
mongo --eval "var DIR=\"${DIR}\"" --quiet --host ${host}  -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase admin ${MONGO_DB} ${script}
