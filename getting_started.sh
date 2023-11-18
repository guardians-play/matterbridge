#!/bin/bash

# set -xe
# Environment variables
# phoneNumber e.g 972505152183
# userStorage e.g. s3://us-west-2-guardian-data154316-dev/private/us-west-2:6da317cd-7edd-472d-8d3c-6aee1296ac3c/phone-data/972542524544/

S3_BUCKET="887615018263-us-west-2-guardian-data"
GROUP_FILE="groups.json"
QR_FILE="qr.png"
CONF_FILE="matterbridge.toml"

clean() {
    echo "cleaning"
    rm -f ${QR_FILE} ${CONF_FILE} ${GROUP_FILE} session+${phoneNumber}.gob.db
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
  aws s3 cp $1 ${userStorage}
}

# Wait for file to be written on filesystem
wait_for_file() {
  while [ ! -f $1 ]; do
    sleep 1
    echo "waiting for $1 to arrive"
  done
  echo "$1 file arrived"
}

# Run clean function
clean

# Start
echo "getting started with phone $phoneNumber"

echo "editing toml"
sed "s|PHONE|$phoneNumber|" template.toml > ${CONF_FILE}

echo "running matterbrigde in backgroud"
/etc/matterbridge/matterbridge &
sleep 1

# QR code
check_if_matter_up
wait_for_file ${QR_FILE} 
upload_file_to_s3 ${QR_FILE}

# Group file
check_if_matter_up
wait_for_file ${GROUP_FILE}
upload_file_to_s3 ${GROUP_FILE}

# Session File
upload_file_to_s3 session+${phoneNumber}.gob.db