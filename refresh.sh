#!/bin/bash

set -e 

# set -x
# Environment variables:
# phoneNumber e.g 972505152183
# userStorage e.g. s3://us-west-2-guardian-data154316-dev/private/us-west-2:6da317cd-7edd-472d-8d3c-6aee1296ac3c/phone-data/972542524544/

# files
GROUP_FILE="groups.json"
CONF_FILE="matterbridge.toml"
LOCAL_CONF_PATH="/etc/matterbridge"

echo "GROUP_FILE: ${GROUP_FILE}"
echo "CONF_FILE: ${CONF_FILE}"
echo "LOCAL_CONF_PATH: ${LOCAL_CONF_PATH}"

echo "refresh groups -> started"

check_env_exists() {
  if [[ -n "$phoneNumber" && -n "$userStorage" ]]; then
    echo "variables are set"
    echo "Working with phone numerb ${phoneNumber} and s3 path ${userStorage}"
  else
    echo "One or both variables are not set. Exiting."
    echo "phoneNumber: ${phoneNumber}"
    echo "userStorage: ${userStorage}"
    exit 1
  fi
}

clean() {
    echo "cleaning"
    rm -f ${QR_FILE} ${CONF_FILE} ${GROUP_FILE} session+${phoneNumber}.gob.db
}

clean_cloud() {
  aws s3 rm ${userStorage}/${GROUP_FILE}
}

remove_trailing_slash() {
    local input="$1"
    # Remove trailing "/"
    userStorage="${input%/}"
    echo "$userStorage"
}

# Check if process is running, for not waiting to the files to arrive
check_if_matter_up() {
    echo "checking if process is up"
    if ! ps aux | grep /etc/matterbridge/matterbridge | grep -v grep; then
        echo "matterbridge process is not running"
        exit 1
    fi
}

# Upload to S3
upload_file_to_s3() {
  echo "uploading $1 to ${userStorage}"
  aws s3 cp $1 ${userStorage}/$1
}

# Download from S3
download_file_from_s3() {
  echo "downloading $1 from $userStorage"
  aws s3 cp ${userStorage}/$1 ${LOCAL_CONF_PATH}/
}

# Wait for file to be written on filesystem
wait_for_file() {
  while [ ! -f $1 ]; do
    sleep 1
    echo "waiting for $1 to arrive"
  done
  echo "$1 file arrived"
}

# environment
echo "working on $phoneNumber"
echo "destination bucket $userStorage"

# check environment varaibles
check_env_exists
remove_trailing_slash $userStorage
echo "userStorage: $userStorage"

# Run clean function
clean
clean_cloud

# Start
echo "refresh groups with phone $phoneNumber"

# Edit config.toml with phone number
echo "editing toml"
sed "s|PHONE|$phoneNumber|" template.toml > ${CONF_FILE}

# Download session file from user storage
download_file_from_s3 session+${phoneNumber}.gob.db

# Download config file from user storage
download_file_from_s3 ${CONF_FILE}

# Starting matterbridge
echo "debug"
cat ${LOCAL_CONF_PATH}/${CONF_FILE}
echo "running matterbrigde in backgroud"
/etc/matterbridge/matterbridge -conf ${LOCAL_CONF_PATH}/${CONF_FILE} &
sleep 1

# Group file
check_if_matter_up
wait_for_file ${GROUP_FILE}
upload_file_to_s3 ${GROUP_FILE}

# Finish
echo "refresh groups -> finished"