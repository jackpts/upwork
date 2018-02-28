#!/usr/bin/env bash

# This script was composed by Yauheni Pauliukanets to resolve IPs from hostlist file

bold=$(tput bold)
normal=$(tput sgr0)
OUT_LOG=out.log

if [[ -z $1 ]]; then
    echo Please specify the hostlist file name as a parameter!
    exit 1
fi

if [[ ! -f $1 ]]
 then
    echo Wrong file format or file not found!
 else
	while IFS='' read -r line || [[ -n "$line" ]]; do
	    echo "${bold}$line${normal}:"
	    echo $line >> out.log
	    IPList=`nslookup $line | grep Address | awk '{if(NR>1)print $2;fi}'`
	    printf "$IPList\n\n"
	    printf "$IPList\n\n" >> out.log
	done < "$1"
fi