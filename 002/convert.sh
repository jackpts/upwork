#!/usr/bin/env bash

#CONSTANTS
SECTION_START='<person id='
SECTION_END='</person>'
LOG_FILE_NAME='conversion.log'
#INPUT_FILE_NAME='account.xml'
OUTPUT_FILE_NAME='account.csv'

SECTION_OPEN_STATUS=0

#exec >${OUTPUT_FILE_NAME}
exec 3>${LOG_FILE_NAME}
echo `date` >&3

#cat <${INPUT_FILE_NAME}
#while read line; do
  #echo $line
  #echo "first line of data"

#    if [ ! -z $SECTION_OPEN_STATUS ]; then
#        echo $line
#        echo $SECTION_OPEN_STATUS >&2;
#    fi

#    if [[ "$line" == *"$SECTION_START"* ]]; then SECTION_OPEN_STATUS=1; fi
#    if [[ "$line" == *"$SECTION_END"* ]]; then SECTION_OPEN_STATUS=0; fi

#    echo $SECTION_OPEN_STATUS

#done >&-
#done >account.csv

if [[ -f "$1" ]]
then
    while IFS='' read -r line || [[ -n "$line" ]]; do
    #    echo "Text read from file: $line"
        if [ $SECTION_OPEN_STATUS -eq 1 ] && [[ "$line" != *"$SECTION_END"* ]]
        i='payee_name' #TODO: for in()

        then
            case $line in
                *"$i"*)
                    START_POS=`expr index "$line" '<$i>'`
                    START_POS="$((START_POS + ${#i} + 1))"
                    END_POS=`awk -v a="$line" -v b="</$i>" 'BEGIN{print index(a,b)}'`
                    END_POS="$((END_POS - 1 - $START_POS))"
                    echo ${line:$START_POS:$END_POS}
                    ;;
            esac
        fi

        if [[ "$line" == *"$SECTION_START"* ]]; then SECTION_OPEN_STATUS=1; fi
        if [[ "$line" == *"$SECTION_END"* ]]; then SECTION_OPEN_STATUS=0; fi
    #    echo "Open status=="$SECTION_OPEN_STATUS



    done < "$1"
fi

#echo error message >&2;

#exec >&-
#exec &>-  # close the data output file
echo "output file closed" >&3