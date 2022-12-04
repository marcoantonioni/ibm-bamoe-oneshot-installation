#!/bin/bash

PGCONF=$1
if [ -f "${PGCONF}" ]; then
    cp "${PGCONF}" "${PGCONF}-original"
    echo "Backup config file in ${PGCONF}-original"
    echo "Updating password encryption mode in file "${PGCONF}
	sed 's/#password_encryption = md5/password_encryption = scram-sha-256/g' -i ${PGCONF} 
else
    echo "File "${PGCONF}" not found"
	exit
fi
