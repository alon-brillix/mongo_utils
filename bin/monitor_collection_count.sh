#!/bin/bash
[ -f ~/.mongo.env ] && . ~/.mongo.env

usage() {
	local str
	read -d '' str <<-EOF
		Usage $(basename $0) [OPTION]...
		Use this tool to monitor the count of a collection.
		The tool will draw an ongoing graph with icrease(red) and decrease(green) of the count

		OPTIONS
		-h|--help			help - print this help page
		-t|--times=x		times - how many times to check (default: 0 - forever)
		-w|--waitfor=x		wait - how many seconds to wait between each check (default: 1 - second)
		-c|--collection	collection - which collection to check (mandatory)
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

mock() {
	echo $RANDOM
}


getData() {
	mongo --quiet --host ${MONGOS}  -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase admin ${MONGO_DB} --eval "db.${collection}.count()"
}

graph() {
	local stats=("$@")
	local line
	local max
	local min
	local gap
	local prev=-1
	local line1
	local line2
	local line3
	local output

	for line in "${stats[@]}";do # Array
		[[ ${min} == "" ]] && min=${line}
		[[ ${max} == "" ]] && max=${line}
		(( ${min} > ${line} )) && min=${line}
		(( ${max} < ${line} )) && max=${line}
		(( prev == -1 )) && prev=${line}
		gap=$((${line}-${prev}))

		if (( ${gap} < 0 ));then
			#line1+="$(GREEN ${gap}),"
			line1+="${gap},"
			line3+=" ,"
		elif (( ${gap} > 0 ));then
			line1+=" ,"
			#line3+="$(RED ${gap}),"
			line3+="${gap},"
		else
			line1+=" ,"
			line3+=" ,"
		fi
		line2+="${line},"
		prev=${line}
	done # Array

	echo -e "$(GREEN ${line1})\n${line2}\n$(RED ${line3})"
}

getMore() {
	local stats=("$@")
	local limit=5
	#stats+=($(mock))
	stats+=($(getData))
	local size=${#stats[@]}

	while (( ${size} > ${limit} ));do
		stats=("${stats[@]:1}")
		size=${#stats[@]}
	done

	declare -p stats | sed -e 's/^declare -a [^=]*=//'
}

loop() {
	local i=0
	local -a stats
	local title="Wait=${waitfor}s; Times=${times}; Collection=${collection}"
	while (( ${i} < ${times} ||  ${times} == 0 ));do
		statsCommand=$(getMore "${stats[@]}")
		eval "declare -a stats=${statsCommand}"
		printout="["$(date '+%d/%m/%Y %H:%M:%S')"] ${title}\n"$(graph "${stats[@]}" |column -s',' -t)
		i=$((i+1))
		clear
		echo -e "${printout}"
		if (( ${i} < ${times} ||  ${times} == 0 ));then
			sleep ${waitfor}
		fi
	done
}

# Defaults
times=0
waitfor=1

while getopts ":ht:w:c:-:" opt; do
	case ${opt} in
		t)
			times=${OPTARG}
			;;
		w)
			waitfor=${OPTARG}
			;;
		c)
			collection=${OPTARG}
			;;
		-)
			OPT=$(echo ${OPTARG}|cut -d'=' -f1)
			VAL=$(echo ${OPTARG}|cut -d'=' -f2)
			case ${OPT} in
				times)
					times=${VAL}
					;;
				wait)
					waitfor=${VAL}
					;;
				collection)
					collection=${VAL}
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
loop 
