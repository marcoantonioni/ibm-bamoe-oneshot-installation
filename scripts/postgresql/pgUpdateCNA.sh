#!/bin/bash

PGCLIENTAUTH=$1
if [ -f "${PGCLIENTAUTH}" ]; then
    cp "${PGCLIENTAUTH}" "${PGCLIENTAUTH}-original"
    echo "Backup config file in ${PGCLIENTAUTH}-original"
    echo "Updating client auth encryption mode in file "${PGCLIENTAUTH}
	sed 's/host.*all.*all.*127.0.0.1\/32.*ident/host\tall\t\tall\t\t127.0.0.1\/32\t\tscram-sha-256/g' -i ${PGCLIENTAUTH}
else
    echo "File "${PGCLIENTAUTH}" not found"
	exit
fi
