#!/bin/bash -x 

input_file="$1"
output_file='output.json'
tmp_file='tmp_output.json'
tests_json=""

# Check if input file path is provided as argument
if [ $# -eq 0 ]; then
  echo "Error: Please provide the path to input.txt file as an argument."
  exit 1
fi

# Define a function to log messages
log_message() {
  local level="${1}"  # e.g., INFO, DEBUG, ERROR
  local msg="${2}"
  echo "[${level}] ${msg}" # Output to stdout
  logger -p "${level}" -t "bash script" "${msg}"
}

# Read the input file

# Logging script start with input file
log_message "INFO" "Script started with input file: ${input_file}"
log_message "ERROR" "An error occurred: $?"

# reding & parsing the input .csv file
log_message "DEBUG" "Processing file: ${input_file}"

# Process the text file line by line
while IFS= read -r line || [ -n "$line" ]; do
  # Check for line containing test name & parse it
if [[ $line == *"["*"]"* ]]; then
testName="$(awk '/^\[/ {print $2,$3;}' <<< $line)"
testName_json="\"testName\":\"$testName\","
fi

  # Check for line starting with "not" & parse it
if [[ $line =~ ^not ]]; then
  duration="$(awk '/^not ok/ {print $NF}' <<< $line)"
  test_count="$(awk '/^not ok/ {print $3}' <<< $line)"
  name="$(awk -F"$test_count  " '{print $2}' <<< $line | awk -F", $duration" '{print $1}')"
  status="false"
  test_json="{\"name\":\"$name\",\"status\":$status,\"duration\":\"$duration\"}"
  tests_json="${tests_json:+$tests_json,}$test_json"
fi

  # Check for line starting with "ok" & parse it
if [[ $line =~ ^ok ]]; then
  duration="$(awk '/^ok/ {print $NF}' <<< $line)"
  test_count="$(awk '/^ok/ {print $2}' <<< $line)"
  name="$(awk -F"$test_count  " '{print $2}' <<< $line | awk -F", $duration" '{print $1}')"
  status="true"
  test_json="{\"name\":\"$name\",\"status\":$status,\"duration\":\"$duration\"}"
  tests_json="${tests_json:+$tests_json,}$test_json"
fi

  # Check for line starting with digits & parse it
if [[ $line =~ ^[0-9] ]]; then
  duration="$(awk '{print $NF}' <<< $line)"
  success="$(awk '{print $1}' <<< $line)"
  failed="$(awk '{print $6}' <<< $line)"
  rating="$(awk -F'rated as ' '{print $2}' <<< $line | awk -F'%,' '{print $1}')"
  summary_json="\"summary\":{\"success\":$success,\"failed\":$failed,\"rating\":$rating,\"duration\":\"$duration\"}"
fi

  # Gluing the full .json object 
full_json="{$testName_json\"tests\":[$tests_json],$summary_json}"

done < $input_file

log_message "ERROR" "An error occurred: $?"

  # Parsing glued .json object by using "jq" util from the current repo
#echo -e $full_json | ./jq -e . > $output_file
#cat $output_file

echo -e ${full_json} > ${output_file}
./jq -e . ${output_file} > ${tmp_file} && mv ${tmp_file} ${output_file}

log_message "ERROR" "An error occurred: $?"
log_message "INFO" "Script completed successfully: New file: ${output_file}"
