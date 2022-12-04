#!/bin/bash

USER_PASSWORD=admin:passw0rd
SERVER_URL=http://localhost:8080/kie-server
CTR_ID=TestTimer1_1.0.0-SNAPSHOT
PROCESS_TEMPL_ID="TestTimer1.TestTimer1"
MAX_P=1000

for (( c=1; c<=$MAX_P; c++ )) 
do 
    sleep 0.1 
    DELAY=$(( $RANDOM % 50 + 10 ))
    curl -s -k -u ${USER_PASSWORD} -H 'content-type: application/json' -H 'accept: application/json' -X POST ${SERVER_URL}/services/rest/server/containers/${CTR_ID}/processes/${PROCESS_TEMPL_ID}/instances  -d "{\"delay\":\"PT${DELAY}S\"}"
done
