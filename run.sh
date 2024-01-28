#!/bin/bash
#
# Matterbridge runtime 
#
# set -x
# Environment variables:
# phoneNumber e.g 972505152183
# userStorage e.g. s3://us-west-2-guardian-data154316-dev/private/us-west-2:6da317cd-7edd-472d-8d3c-6aee1296ac3c/phone-data/${phoneNumber}/

# files
# phoneNumber="972525583454"
CONF_FILE="matterbridge.toml"
SESSION_FILE="session+${phoneNumber}.gob.db"
FILE_DESTINATION="/etc/matterbridge/"
# userStorage="s3://us-west-2-guardian-data154316-dev/private/us-west-2:6da317cd-7edd-472d-8d3c-6aee1296ac3c/phone-data/${phoneNumber}"

# download from S3
download_from_s3() {
    echo "Downloading $1 to ${userStorage}"
    aws s3 cp $userStorage/$1 $FILE_DESTINATION/$1
}

# environment debug
echo "working on phoneNumber: $phoneNumber"
echo "bucket: $userStorage"
echo "session file: ${SESSION_FILE}"

# Download config, and session db file from s3 userStorage
download_from_s3 ${CONF_FILE}
download_from_s3 ${SESSION_FILE}

echo "Starting matterbrigde"
# /etc/matterbridge/matterbridge
exec "$@"

