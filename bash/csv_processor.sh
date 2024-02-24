#!/bin/bash
INPUT=$1
OLDIFS=$IFS
IFS=','
email_sufix='@abs.com'
OUTPUT_FILE='accounts_new.csv'

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

while read n1 location_id name role space
do
        echo "${n1},${location_id},${name},${role},${space},"

done < ${INPUT}

echo ""

declare -A email_map

while read n1 location_id name role space
do
      firstname=$(echo "${name}" | cut -d ' ' -f 1)
      lastname=$(echo "${name}" | cut -d ' ' -f 2)

      formatted_fnl="$(tr '[:lower:]' '[:upper:]' <<< ${firstname:0:1})"
      formatted_fnrl="$(tr '[:upper:]' '[:lower:]' <<< ${firstname:1})"
      formatted_firstname="${formatted_fnl}${formatted_fnrl}"

      formatted_lnfl="$(tr '[:lower:]' '[:upper:]' <<< ${lastname:0:1})"
      formatted_lnrl="$(tr '[:upper:]' '[:lower:]' <<< ${lastname:1})"
      formatted_lastname="${formatted_lnfl}${formatted_lnrl}"

      formatted_name="${formatted_firstname} ${formatted_lastname}"


      email_prefix="$(tr '[:upper:]' '[:lower:]' <<< "${firstname^}${lastname}")"
      email_addr="${email_prefix}${email_sufix}"
      #echo "email: ${email_addr}"

      if [[ -n "${email_map[${email_addr}]}" ]]; then
        # if email is already present in map add  location_id
        new_email_addr="${email_prefix}${location_id}${email_sufix}"
        email_map[${email_addr}]=${new_email_addr}
      else
        # if email isn't in map then add it to map
        email_map[${email_addr}]=${email_addr}
      fi

      echo -e "${n1},${location_id},${formatted_name},${role},${email_map[${email_addr}]}," >> ${OUTPUT_FILE}

done < ${INPUT}

IFS=$OLDIFS
cat ${OUTPUT_FILE}
