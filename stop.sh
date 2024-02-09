#!/usr/bin/env bash

COFF="\033[0m"
CINFO="\033[0;34m"
CSUCCESS="\033[0;32m"
CERROR="\033[0;31m"

handle_exit_code() {
	ERROR_CODE="$?"
	if [[ ERROR_CODE != "0" ]]; then
		echo " > ${CERROR}An error occurred. Exiting with code ${ERROR_CODE}.${COFF}"
		exit ${ERROR_CODE}
	else
		echo " > ${CSUCCESS}Script execution completed!${COFF}"
		exit ${ERROR_CODE}
	fi
}

trap "handle_exit_code" EXIT

echo " > ${CINFO}Stopping docker container stack...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-tor.yml --file ./compose/docker-bitcoin.yml --file ./compose/docker-electrs.yml down