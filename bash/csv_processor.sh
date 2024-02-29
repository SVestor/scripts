#!/bin/bash

INPUT=$1
OLDIFS=${IFS}
IFS=','
email_sufix='@abc.com'
OUTPUT_FILE='accounts_new.csv'
TMP_FILE='tmp.csv'

[ ! -f ${INPUT} ] && { echo "${INPUT} file not found"; exit 5; }

declare -A email_map
declare -A location_id_map
declare -A id_map
declare -A name_map
declare -A title_map
declare -A department_map
declare -A new_email_map
declare -A email_prefix_map
declare -A email_sufix_map
declare -i id_count=0

# Define a function to log messages
log_message() {
  local level="${1}"  # e.g., INFO, DEBUG, ERROR
  local msg="${2}"
  logger -p "${level}" -t "bash script" "${msg}"
}

# Logging script start with input file
log_message "INFO" "Script started with input file: ${INPUT}"
log_message "ERROR" "An error occurred: $?"

# reding & parsing the input .csv file 
log_message "DEBUG" "Processing file: ${INPUT}"

while read id location_id name title email department
do
    if [[ ${title} == *\"* ]]; then
        title="${title},${email}"
        email=""
    fi

    firstname=$(echo "${name}" | cut -d ' ' -f 1)
    lastname=$(echo "${name}" | cut -d ' ' -f 2)

    formatted_fnl="$(tr '[:lower:]' '[:upper:]' <<< ${firstname:0:1})"
    formatted_fnrl="$(tr '[:upper:]' '[:lower:]' <<< ${firstname:1})"
    formatted_firstname="${formatted_fnl}${formatted_fnrl}"

    formatted_lnfl="$(tr '[:lower:]' '[:upper:]' <<< ${lastname:0:1})"
    formatted_lnrl="$(tr '[:upper:]' '[:lower:]' <<< ${lastname:1})"
    formatted_lastname="${formatted_lnfl}${formatted_lnrl}"

    if [[ ${formatted_lastname} == *\-* ]]; then
        prefix="${formatted_lastname%%-*}"
        suffix="${formatted_lastname#*-}"
        suffix="${suffix^}"
        formatted_lastname="${prefix}-${suffix}"
    fi

    formatted_name="${formatted_firstname} ${formatted_lastname}"


    email_prefix="$(tr '[:upper:]' '[:lower:]' <<< "${firstname:0:1}${lastname}")"
    email_addr="${email_prefix}${email_sufix}"

    id_map[${id_count}]=${id}
    location_id_map[${id_count}]=${location_id}
    name_map[${id_count}]=${formatted_name}
    title_map[${id_count}]=${title}
    email_map[${id_count}]=${email_addr}
    department_map[${id_count}]=${department}

    email_prefix_map[${id_count}]=${email_prefix}
    email_sufix_map[${id_count}]=${email_sufix}

    id_count_map[${id_count}]=${id_count}
    id_count+=1

done < ${INPUT}

log_message "ERROR" "An error occurred: $?"

# replicating arrays with the order saving
new_email_map=()
for key in "${!id_count_map[@]}"; do
  new_email_map+=("$key" "${email_map[$key]}")
done

log_message "ERROR" "An error occurred: $?"

# checking for identical emails & adding location_id to eq email_addr
for i in "${!id_count_map[@]}"; do
    for key1 in "${!id_count_map[@]}"; do
         if [[ ${i} != ${key1} ]]; then
            if [[ "${email_map[${key1}]}" == "${email_map[${i}]}" ]]; then
              email_addr1=${email_prefix_map[${i}]}${location_id_map[${i}]}${email_sufix_map[${i}]}
              email_addr2=${email_prefix_map[${key1}]}${location_id_map[${key1}]}${email_sufix_map[${key1}]}
              new_email_map[${i}]=${email_addr1}
              new_email_map[${key1}]=${email_addr2}
            fi
         fi
    done

echo -e "${id_map[${i}]},${location_id_map[${i}]},${name_map[${i}]},${title_map[${i}]},${new_email_map[${i}]},${department_map[${i}]}" >> ${OUTPUT_FILE}

done

log_message "ERROR" "An error occurred: $?"

# overwriting the first line in the parsed result
tail -n +2 ${OUTPUT_FILE} > ${TMP_FILE}
head -n 1 ${INPUT} > ${OUTPUT_FILE}
cat ${TMP_FILE} >> ${OUTPUT_FILE}
rm -rf ${TMP_FILE}
IFS=${OLDIFS}

log_message "ERROR" "An error occurred: $?"
log_message "INFO" "Script completed successfully: New file: ${OUTPUT_FILE}"
