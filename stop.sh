#!/usr/bin/env bash

COFF="\033[0m"
CINFO="\033[01;34m"
CSUCCESS="\033[0;32m"
CERROR="\033[0;31m"

handle_exit_code() {
	ERROR_CODE="$?"
	if [[ ${ERROR_CODE} != "0" ]]; then
		echo -e " > ${CERROR}An error occurred. Exiting with code ${ERROR_CODE}.${COFF}"
		exit ${ERROR_CODE}
	else
		echo -e " > ${CSUCCESS}Script execution completed!${COFF}"
		exit ${ERROR_CODE}
	fi
}

trap "handle_exit_code" EXIT

STACK_DOCKER_PRUNE="False"

echo -e " > ${CINFO}Stopping docker container stack...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-tor.yml --file ./compose/docker-bitcoin.yml --file ./compose/docker-electrs.yml down

if [[ ${STACK_DOCKER_PRUNE} == "True" ]]; then
	echo -e " > ${CINFO}Commencing docker system prune...${COFF}"
	docker system prune -f
	echo -e " > ${CSUCCESS}Docker system prune completed!${COFF}"
else
	echo -e " > ${CWARN}Docker system prune skipped!${COFF}"
fi