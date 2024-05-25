#!/usr/bin/env bash

# Console colors for better legibility.
COFF="\033[0m"
CINFO="\033[01;34m"
CSUCCESS="\033[0;32m"
CWARN="\033[0;33m"
CLINK="\033[0;35m"
CERROR="\033[0;31m"

# Script error handling.
handle_exit_code() {
	ERROR_CODE="$?"
	if [[ ${ERROR_CODE} != "0" ]]; then
		echo -e " > ${CERROR}An error occurred somewhere. Exiting with code ${ERROR_CODE}.${COFF}"		
		exit ${ERROR_CODE}
	else
		echo -e " > ${CSUCCESS}Script execution completed!${COFF}"
		exit ${ERROR_CODE}
	fi
}

trap "handle_exit_code" EXIT

echo -e " > ${CINFO}Proceeding to pull latest update...${COFF}"
echo -e " > ${CINFO}Stashing local changes...${COFF}"
git stash
echo -e " > ${CINFO}Pulling latest commit from master branch...${COFF}"
git pull origin master
echo -e " > ${CINFO}Re-applying local changes...${COFF}"
git stash apply
echo -e " > ${CSUCCESS}Updates have been applied!${COFF}"