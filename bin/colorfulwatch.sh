#!/bin/bash

while true; do
	output=$(${SHELL-/bin/sh} -c "$*")
	clear
	printf "[%s] %s:\n" "$(date '+%d/%m/%Y %H:%M:%S')" "$*"
	echo -e "${output}"
	sleep 2
done
