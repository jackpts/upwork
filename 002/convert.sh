#!/usr/bin/env bash

# This script has been created by Yauheni Pauliukanets
# to convert XML files to CSV
# Please specify ACCOUNT_ARRAY and SECTION_START/SECTION_END
# constants below for the correct work with YOUR XML file structure!

#CONSTANTS
SECTION_START='<person id='
SECTION_END='</person>'
LOG_FILE_NAME='conversion.log'
#INPUT_FILE_NAME='account.xml'
#OUTPUT_FILE_NAME='account.csv'

SECTION_OPEN_STATUS=0
ACCOUNT_ARRAY=('payee_name' 'reference' 'value' 'date' 'saldo')
USER_LINE=''
OUT_ARRAY=('')
counter=0

exec 3>>${LOG_FILE_NAME}
echo '----------------------------' >&3
echo `date` >&3

if [[ -z $1 ]]; then
    echo Please specify input xml file as a parameter! >&2;
    echo 'No Input parameter found!' >&3
    exit 0
fi

if [[ -f "$1" ]]
then
    INPUT_FILE_NAME=$1
    echo "Specified INPUT file as: $INPUT_FILE_NAME" >&3
    OUTPUT_FILE_NAME="${INPUT_FILE_NAME:0:-4}.csv"
    echo "OUTPUT file will be: $OUTPUT_FILE_NAME" >&3
    exec 5>${OUTPUT_FILE_NAME}

    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [ $SECTION_OPEN_STATUS -eq 1 ] && [[ "$line" != *"$SECTION_END"* ]] ;then
            for aa in ${ACCOUNT_ARRAY[@]}
                do
                    case $line in
                        *"$aa"*)
                            START_POS=`expr index "$line" '<$aa>'`
                            START_POS="$((START_POS + ${#aa} + 1))"
                            END_POS=`awk -v a="$line" -v b="</$aa>" 'BEGIN{print index(a,b)}'`
                            END_POS="$((END_POS - 1 - $START_POS))"
                            PART=${line:$START_POS:$END_POS}
                            USER_LINE+="$PART, "
                            LOG="Found part that meet: $aa - $PART"
                            echo $LOG >&3
                            ;;
                    esac
                done
        fi

        if [[ "$line" == *"$SECTION_START"* ]]
            then
                SECTION_OPEN_STATUS=1;
                USER_LINE=''
                echo '...Section START found.' >&3
        fi

        if [[ "$line" == *"$SECTION_END"* ]]
            then
                SECTION_OPEN_STATUS=0;
                if [[ ${#USER_LINE} -gt 2 ]]; then
                    OUT_LINE=${USER_LINE:0:-2}
                    ((counter++))
                    echo "$counter. $OUT_LINE"
                    echo $OUT_LINE >&5
                else
                    echo '===DEFECT Section! NONE found!===' >&3
                fi
                echo '...Section END found.' >&3
        fi
    done < "$1"
else
    echo Sorry, wrong xml file! >&2;
    echo "Mentioned file ($1) doesn't exist!" >&3
    exit 1
fi

if [[ -n ${#counter} ]]; then
    printf "%s %s $counter records found in total.\n"
fi

echo "LOG file closed." >&3
exec >&- # close files