#!/bin/bash

# build latest
docker build -t getting_started -f Dockerfile_whatsappmulti_getting_started .

# Grab aws key
KEY=$(cat ~/.aws/credentials  | grep -A 2 '\[c\]' | grep access_key_id | cut -d "=" -f2)
SECRET=$(cat ~/.aws/credentials  | grep -A 2 '\[c\]' | grep secret | cut -d "=" -f2)

# run
docker run -e AWS_REGION=us-west-2 -e AWS_ACCESS_KEY_ID=${KEY} -e AWS_SECRET_ACCESS_KEY=${SECRET} \
    -e phoneNumber=972505152183 \
    -e userStorage=s3://us-west-2-guardian-data154316-dev/private/us-west-2:0dbfd95e-2687-4cf0-950b-6232cdc14f64/phone-data/972505152183 \
    getting_started
