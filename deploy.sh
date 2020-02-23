#!/bin/bash
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
	echo "This file should be sourced only, not be executed!"
	exit 1
fi

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
pushd ${DIR} > /dev/null
grep ${PWD} ~/.bash_profile || sed -i "/^PATH=.*/ s+$+:${PWD}/bin+" ~/.bash_profile
echo $PATH|grep ${PWD} || export PATH="$PATH:${PWD}/bin"
popd > /dev/null
