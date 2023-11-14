#!/bin/bash

set -x

S3_BUCKET="887615018263-us-west-2-guardian-data"

PHONE="${1:-972547789125}"

clean() {
    echo "cleaning"
    rm -f qr.png matterbridge.toml groupsInfo.jsonb session+*.gob.db
}

# Check if process is running, for not waiting to the files to arrive
check_if_matter_up() {
    echo "checking if process is up"
    if ! ps aux | grep matterbridge | grep -v grep; then
        echo "matterbridge process is not running"
        exit 1
    fi
}

# Run clean function
clean

# Start
echo "getting started with phone $PHONE"

echo "editing toml"
sed "s|PHONE|$PHONE|" template.toml > matterbridge.toml

echo "running matterbrigde in backgroud"
./matterbridge &
sleep 1

check_if_matter_up
while [ ! -f qr.png ]; do
  sleep 1
  echo "waiting for file to arrive"
done
echo "qr.png file arrived"

echo "uploading qr.png to S3"
aws s3 cp qr.png s3://${S3_BUCKET}/phone-data/${PHONE}/

echo "waiting for groupsInfo.json file"
check_if_matter_up
while [ ! -f groupsInfo.json ]; do
  sleep 1
  echo "waiting for file to arrive"
done
echo "groupsInfo.json file arrived"

echo "uploading groupsInfo.json to S3"
aws s3 cp groupsInfo.json s3://${S3_BUCKET}/phone-data/${PHONE}/

echo "uploading session file to S3"
aws s3 cp session+${PHONE}.gob.db s3://${S3_BUCKET}/phone-data/${PHONE}/