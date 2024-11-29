#!/usr/bin/env bash

# Console colors for better legibility.
COFF="\033[0m"
CINFO="\033[01;34m"
CSUCCESS="\033[0;32m"
CWARN="\033[0;33m"
CLINK="\033[0;35m"
CERROR="\033[0;31m"

# Current version of the script.
CURRENT_VERSION="v.1.4.0"

# Initial launch identifier.
INIT_LAUNCH="False"
INIT_LAUNCH_FILE="./volumes/.init"

# Set bitcoin network used. Default is mainnet. Other options are testnet, regtest and signet.
STACK_CRYPTO_NETWORK="mainnet"

# Toggle optional script features. Change this if needed, as per your preference.
STACK_CHECK_UPDATES="False" ## Check for system updates using APT package manager.
STACK_SET_PERMISSIONS="False" ## Set permissions for other script files at launch. Best turned off after initial run.
STACK_RUN_LIGHTNING_SERVER="False" ## Turn on the lightning server.
STACK_RUN_MEMPOOL_SPACE="False" ## Run mempool.space explorer instead of the default btc-rpc-explorer.
STACK_RUN_EXTRA_ORDINALS="False" ## Run the Ordinals container from the extras stack.
STACK_RUN_EXTRA_ADGUARD="False" ## Run the Adguard container from the extras stack.
STACK_RUN_EXTRA_NOSTR_WALLET_CONNECT="False" ## Run the Nostr Wallet Connect container from the extras stack.
STACK_RUN_EXTRA_BACK_THAT_MAC="False" ## Run the Back That Mac container from the extras stack.
STACK_RUN_EXTRA_LLAMA_GPT="False" ## Run the Llama GPT container from the extras stack. MUST HAVE MINIMUM 6GB RAM AND 10GB STORAGE SPACE FREE!!!.
STACK_RUN_EXTRA_LIGHTNING_TERMINAL="False" ## Run the Lightning Terminal container from the extras stack.
STACK_RUN_EXTRA_MYSPEED="False" ## Run the My Speed container from the extras stack.

# Allocated container IP. Change this if needed, as per your preference.
STACK_NETWORK_SUBNET="10.21.0.0/16"
STACK_TOR_IP="10.21.22.1"
STACK_I2PD_IP="10.21.22.2"
STACK_BITCOIND_IP="10.21.22.3"
STACK_BITCOIN_GUI_IP="10.21.22.4"
STACK_ELECTRS_IP="10.21.22.5"
STACK_ELECTRS_GUI_IP="10.21.22.6"
STACK_MEMPOOL_IP="10.21.22.7"
STACK_LIGHTNING_NODE_IP="10.21.22.8"
STACK_LIGHTNING_GUI_IP="10.21.22.9"
STACK_MEMPOOL_API_IP="10.21.22.20"
STACK_MEMPOOL_DB_IP="10.21.22.21"
STACK_EXTRAS_ORDINALS_IP="10.21.22.30"
STACK_EXTRAS_ADGUARD_IP="10.21.22.31"
STACK_EXTRAS_NOSTR_WALLET_CONNECT_IP="10.21.22.32"
STACK_EXTRAS_BACK_THAT_MAC_IP="10.21.22.33"
STACK_EXTRAS_TIMEMACHINE_IP="10.21.22.34"
STACK_EXTRAS_LLAMA_GPT_API_IP="10.21.22.35"
STACK_EXTRAS_LLAMA_GPT_UI_IP="10.21.22.36"
STACK_EXTRAS_LIGHTNING_TERMINAL_IP="10.21.22.37"
STACK_EXTRAS_MYSPEED_IP="10.21.22.38"

# Allocated container port. Change this if needed, as per your preference.
STACK_TOR_SOCKS_PORT="9052"
STACK_TOR_CONTROL_PORT="9053"
STACK_I2PD_PORT="7656"
STACK_BITCOIND_RPC_PORT="8332"
STACK_BITCOIND_P2P_PORT="8333"
STACK_BITCOIND_TOR_PORT="8334"
STACK_BITCOIND_PUB_RAW_BLOCK_PORT="28332"
STACK_BITCOIND_PUB_RAW_TX_PORT="28333"
STACK_ELECTRS_PORT="50001"
STACK_LIGHTNING_NODE_PORT="9735"
STACK_LIGHTNING_NODE_REST_PORT="8080"
STACK_LIGHTNING_NODE_GRPC_PORT="10009"
STACK_BITCOIN_GUI_PORT="3005"
STACK_ELECTRS_GUI_PORT="3006"
STACK_MEMPOOL_PORT="3007"
STACK_LIGHTNING_GUI_PORT="3008"
STACK_MEMPOOL_API_PORT="3010"
STACK_EXTRAS_ORDINALS_PORT="3030"
STACK_EXTRAS_ADGUARD_PORT="3031"
STACK_EXTRAS_NOSTR_WALLET_CONNECT_PORT="3032"
STACK_EXTRAS_BACK_THAT_MAC_PORT="3033"
STACK_EXTRAS_LLAMA_GPT_UI_PORT="3034"
STACK_EXTRAS_LIGHTNING_TERMINAL_PORT="3035"
STACK_EXTRAS_MYSPEED_PORT="3036"

# Allocated user info. Leave as is, unless you start running into errors.
STACK_UID=$(id -u)
STACK_GID=$(id -g)
STACK_TOR_USER_INFO="${STACK_UID}:${STACK_GID}"
STACK_BITCOIND_USER_INFO="${STACK_UID}:${STACK_GID}"
STACK_ELECTRS_USER_INFO="${STACK_UID}:${STACK_GID}"
STACK_MEMPOOL_USER_INFO="${STACK_UID}:${STACK_GID}"
STACK_LND_USER_INFO="${STACK_UID}:${STACK_GID}"

# Allocated sensitive container variables. It is recommended that you change these, as per your preference.
STACK_BITCOIND_USERNAME="yourfavusername"
STACK_BITCOIND_PASSWORD="yourbitcoinpasswordd" ## Leave blank to generate random password.
STACK_TOR_PASSWORD="yourtorpasswordd"
STACK_MEMPOOL_DB_USERNAME="mempool"
STACK_MEMPOOL_DB_PASSWORD="mempoolpasswordd"
STACK_MEMPOOL_DB_ROOT_PASSWORD="mempoolrootpasswordd"
STACK_TIMEMACHINE_USERNAME="timemachine"
STACK_TIMEMACHINE_PASSWORD="timemachinepasswordd"
STACK_TIMEMACHINE_GROUPNAME="timemachine"
STACK_OPENAI_API_KEY="sk-XXXXXXXXXXXXXXXXXXXX"
STACK_LIGHTNING_TERMINAL_PASSWORD="lightningterminalpasswordd"

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

# Breakdown of arguments available for use.
if [[ ${#@} -ne 0 ]] && [[ "${@#"--help"}" = "" ]]; then
	echo -e " > ${CINFO}You can run one of the following arguments at a time:${COFF}"
	echo -e "		${CINFO}script.sh --version (Identify current script version)${COFF}"
	echo -e "		${CINFO}script.sh --check (See if there is a new release)${COFF}"
	echo -e "		${CINFO}script.sh --update (Download and update files)${COFF}"
	echo -e "		${CINFO}script.sh --lightning (Run script with lightning node)${COFF}"
	exit 0
fi

# Identify current script version.
if [[ ${#@} -ne 0 ]] && [[ "${@#"--version"}" = "" ]]; then
	echo -e " > ${CINFO}Current version is ${CURRENT_VERSION}.${COFF}"
	exit 0
fi

# Check and compare versions to see if there is a new release. Experimental (untested).
if [[ ${#@} -ne 0 ]] && [[ "${@#"--check"}" = "" ]]; then
	echo -e " > ${CINFO}Checking for updates...${COFF}"
	LATEST_VERSION=$(curl -s https://api.github.com/repos/JDsnyke/crypto/releases/latest | grep -i "tag_name" | awk -F '"' '{print $4}') ## Taken from https://stackoverflow.com/a/75833940
	if [[ ${CURRENT_VERSION} != ${LATEST_VERSION} ]]; then
		echo -e " > ${CERROR}New release available!${COFF}"
		echo -e " > ${CERROR}Run script with --update argument to pull the latest changes.${COFF}"
	else
		echo -e " > ${CSUCCESS}Running latest version already.${COFF}"
	fi
	exit 0
fi

# Download and update local files. Uses git stash to preserve local script changes. Experimental (untested).
if [[ ${#@} -ne 0 ]] && [[ "${@#"--update"}" = "" ]]; then
	bash "update.sh"
fi

# Enable lightning node through terminal argument.
if [[ ${#@} -ne 0 ]] && [[ "${@#"--lightning"}" = "" ]]; then
	echo -e " > ${CSUCCESS}Enabled environment variable for lightning node!${COFF}"
	STACK_RUN_LIGHTNING_SERVER="True"
fi

# Activates initial launch variable.
if [[ ! -f ${INIT_LAUNCH_FILE} ]]; then
	touch "${INIT_LAUNCH_FILE}"
	INIT_LAUNCH="True"
	STACK_SET_PERMISSIONS="True"
fi

# Runs a standard system update and install using APT if active.
if [[ ${STACK_CHECK_UPDATES} == "True" ]]; then
	echo -e " > ${CINFO}Checking system updates...${COFF}"
	sudo apt update
	sudo apt upgrade -y
	echo -e " > ${CSUCCESS}System update check completed!${COFF}"
else
	echo -e " > ${CWARN}System update check skipped!${COFF}"
fi

# Sets file permissions for main scripts. Toggled on to 'True' during initial launch by default and turned off after.
if [[ ${STACK_SET_PERMISSIONS} == "True" ]]; then
	echo -e " > ${CINFO}Setting file permissions...${COFF}"
	chmod u+x "./stop.sh"
	chmod u+x "./update.sh"
	chmod u+x "./scripts/rpcauth.py"
	chmod u+x "./scripts/torauth.py"
	echo -e " > ${CSUCCESS}Setting file permissions completed!${COFF}"
else
	echo -e " > ${CWARN}Setting file permissions skipped!${COFF}"
fi

# Checks if docker is running.
if ( ! docker stats --no-stream > /dev/null); then
	echo -e " > ${CERROR}Docker is not running. Please double check and try again.${COFF}"
	exit 1
fi

# Checks if python 3 is running.
if ( ! python3 --version > /dev/null); then
	echo -e " > ${CERROR}Python 3 is not running. Please double check and try again.${COFF}"
	exit 1
fi

# Determine bitcoin_gui DEFAULT_NETWORK variable.
if [[ ${STACK_CRYPTO_NETWORK} == "mainnet" ]]; then
	export BGUI_NETWORK="main"
fi

# Exporting device hostname to the compose files.
export DEVICE_DOMAIN_NAME=$HOSTNAME

# Variables exported to the docker compose files. Leave as is.
export COMPOSE_IGNORE_ORPHANS="True"
export APP_CRYPTO_NETWORK="${STACK_CRYPTO_NETWORK}"
export APP_NETWORK_SUBNET="${STACK_NETWORK_SUBNET}"
export APP_TOR_PROXY_PASSWORD="${STACK_TOR_PASSWORD}"
export APP_TOR_IP="${STACK_TOR_IP}"
export APP_I2PD_IP="${STACK_I2PD_IP}"
export APP_BITCOIND_IP="${STACK_BITCOIND_IP}"
export APP_BITCOIN_GUI_IP="${STACK_BITCOIN_GUI_IP}"
export APP_ELECTRS_IP="${STACK_ELECTRS_IP}"
export APP_ELECTRS_GUI_IP="${STACK_ELECTRS_GUI_IP}"
export APP_MEMPOOL_IP="${STACK_MEMPOOL_IP}"
export APP_LIGHTNING_NODE_IP="${STACK_LIGHTNING_NODE_IP}"
export APP_LIGHTNING_GUI_IP="${STACK_LIGHTNING_GUI_IP}"
export APP_TOR_SOCKS_PORT="${STACK_TOR_SOCKS_PORT}"
export APP_TOR_CONTROL_PORT="${STACK_TOR_CONTROL_PORT}"
export APP_I2PD_PORT="${STACK_I2PD_PORT}"
export APP_BITCOIND_RPC_PORT="${STACK_BITCOIND_RPC_PORT}"
export APP_BITCOIND_P2P_PORT="${STACK_BITCOIND_P2P_PORT}"
export APP_BITCOIND_PUB_RAW_BLOCK_PORT="${STACK_BITCOIND_PUB_RAW_BLOCK_PORT}"
export APP_BITCOIND_PUB_RAW_TX_PORT="${STACK_BITCOIND_PUB_RAW_TX_PORT}"
export APP_BITCOIN_GUI_PORT="${STACK_BITCOIN_GUI_PORT}"
export APP_ELECTRS_PORT="${STACK_ELECTRS_PORT}"
export APP_ELECTRS_GUI_PORT="${STACK_ELECTRS_GUI_PORT}"
export APP_MEMPOOL_PORT="${STACK_MEMPOOL_PORT}"
export APP_LIGHTNING_NODE_REST_PORT="${STACK_LIGHTNING_NODE_REST_PORT}"
export APP_LIGHTNING_NODE_PORT="${STACK_LIGHTNING_NODE_PORT}"
export APP_LIGHTNING_NODE_GRPC_PORT="${STACK_LIGHTNING_NODE_GRPC_PORT}"
export APP_LIGHTNING_GUI_PORT="${STACK_LIGHTNING_GUI_PORT}"
export APP_TOR_USER_INFO="${STACK_TOR_USER_INFO}"
export APP_BITCOIND_USER_INFO="${STACK_BITCOIND_USER_INFO}"
export APP_ELECTRS_USER_INFO="${STACK_ELECTRS_USER_INFO}"
export APP_MEMPOOL_USER_INFO="${STACK_MEMPOOL_USER_INFO}"
export APP_LND_USER_INFO="${STACK_LND_USER_INFO}"
export APP_MEMPOOL_API_IP="${STACK_MEMPOOL_API_IP}"
export APP_MEMPOOL_API_PORT="${STACK_MEMPOOL_API_PORT}"
export APP_MEMPOOL_DB_IP="${STACK_MEMPOOL_DB_IP}"
export APP_MEMPOOL_DB_USERNAME="${STACK_MEMPOOL_DB_USERNAME}"
export APP_MEMPOOL_DB_PASSWORD="${STACK_MEMPOOL_DB_PASSWORD}"
export APP_MEMPOOL_DB_ROOT_PASSWORD="${STACK_MEMPOOL_DB_ROOT_PASSWORD}"
export APP_EXTRAS_ORDINALS_IP="${STACK_EXTRAS_ORDINALS_IP}"
export APP_EXTRAS_ORDINALS_PORT="${STACK_EXTRAS_ORDINALS_PORT}"
export APP_EXTRAS_ADGUARD_IP="${STACK_EXTRAS_ADGUARD_IP}"
export APP_EXTRAS_ADGUARD_PORT="${STACK_EXTRAS_ADGUARD_PORT}"
export APP_EXTRAS_NOSTR_WALLET_CONNECT_IP="${STACK_EXTRAS_NOSTR_WALLET_CONNECT_IP}"
export APP_EXTRAS_NOSTR_WALLET_CONNECT_PORT="${STACK_EXTRAS_NOSTR_WALLET_CONNECT_PORT}"
export APP_EXTRAS_BACK_THAT_MAC_IP="${STACK_EXTRAS_BACK_THAT_MAC_IP}"
export APP_EXTRAS_BACK_THAT_MAC_PORT="${STACK_EXTRAS_BACK_THAT_MAC_PORT}"
export APP_EXTRAS_TIMEMACHINE_IP="${STACK_EXTRAS_TIMEMACHINE_IP}"
export APP_TIMEMACHINE_USERNAME="${STACK_TIMEMACHINE_USERNAME}"
export APP_TIMEMACHINE_PASSWORD="${STACK_TIMEMACHINE_PASSWORD}"
export APP_TIMEMACHINE_GROUPNAME="${STACK_TIMEMACHINE_GROUPNAME}"
export APP_EXTRAS_LLAMA_GPT_API_IP="${STACK_EXTRAS_LLAMA_GPT_API_IP}"
export APP_OPENAI_API_KEY="${STACK_OPENAI_API_KEY}"
export APP_EXTRAS_LLAMA_GPT_UI_IP="${STACK_EXTRAS_LLAMA_GPT_UI_IP}"
export APP_EXTRAS_LLAMA_GPT_UI_PORT="${STACK_EXTRAS_LLAMA_GPT_UI_PORT}"
export APP_LIGHTNING_TERMINAL_PASSWORD="${STACK_LIGHTNING_TERMINAL_PASSWORD}"
export APP_EXTRAS_LIGHTNING_TERMINAL_IP="${STACK_EXTRAS_LIGHTNING_TERMINAL_IP}"
export APP_EXTRAS_LIGHTNING_TERMINAL_PORT="${STACK_EXTRAS_LIGHTNING_TERMINAL_PORT}"
export APP_EXTRAS_MYSPEED_IP="${STACK_EXTRAS_MYSPEED_IP}"
export APP_EXTRAS_MYSPEED_PORT="${STACK_EXTRAS_MYSPEED_PORT}"

# Pulls latest docker containers as per compose files.
if [[ "${INIT_LAUNCH}" == "True" ]]; then
	echo -e " > ${CINFO}Pulling docker containers...${COFF}"
else
	echo -e " > ${CINFO}Checking for container updates...${COFF}"
fi
docker-compose --log-level ERROR --file ./compose/docker-tor.yml --file ./compose/docker-bitcoin.yml --file ./compose/docker-electrs.yml --file ./compose/docker-lightning.yml --file ./compose/docker-extras.yml pull
echo -e " > ${CSUCCESS}Docker containers have been pulled as needed!${COFF}"

# Hashes provided tor password.
echo -e " > ${CINFO}Hashing tor password...${COFF}"
TOR_HASHED_PASSWORD=$("./scripts/torauth.py")
echo -e " > ${CSUCCESS}Password has been hashed!${COFF}"

# Updates the torrc file.
echo -e " > ${CINFO}Updating the torrc file...${COFF}"
echo "\
SocksPort 0.0.0.0:${STACK_TOR_SOCKS_PORT}
ControlPort 0.0.0.0:${STACK_TOR_CONTROL_PORT}
CookieAuthentication 1
CookieAuthFileGroupReadable 1
HashedControlPassword ${TOR_HASHED_PASSWORD}

# Bitcoin Core P2P Hidden Service
HiddenServiceDir /data/app-bitcoin-p2p
HiddenServicePort ${STACK_BITCOIND_P2P_PORT} ${STACK_BITCOIND_IP}:${STACK_BITCOIND_TOR_PORT}

# Bitcoin Core RPC Hidden Service
HiddenServiceDir /data/app-bitcoin-rpc
HiddenServicePort ${STACK_BITCOIND_RPC_PORT} ${STACK_BITCOIND_IP}:${STACK_BITCOIND_RPC_PORT}

# Electrs RPC Hidden Service
HiddenServiceDir /data/app-electrs-rpc
HiddenServicePort ${STACK_ELECTRS_PORT} ${STACK_ELECTRS_IP}:${STACK_ELECTRS_PORT}

# Mempool Explorer RPC Hidden Service
HiddenServiceDir /data/app-mempool-rpc
HiddenServicePort ${STACK_MEMPOOL_PORT} ${STACK_MEMPOOL_IP}:${STACK_MEMPOOL_PORT}

# Lightning REST Hidden Service
HiddenServiceDir /data/app-lightning-rest
HiddenServicePort ${STACK_LIGHTNING_NODE_REST_PORT} ${STACK_LIGHTNING_NODE_IP}:${STACK_LIGHTNING_NODE_REST_PORT}

# Lightning GRPC Hidden Service
HiddenServiceDir /data/app-lightning-grpc
HiddenServicePort ${STACK_LIGHTNING_NODE_GRPC_PORT} ${STACK_LIGHTNING_NODE_IP}:${STACK_LIGHTNING_NODE_GRPC_PORT}\
" | tee ./volumes/tor/torrc/torrc > /dev/null
echo -e " > ${CSUCCESS}The torrc file has been updated!${COFF}"

# Generating command arguments for i2pd container.
BIN_ARGS_I2PD=()
BIN_ARGS_I2PD+=( "--sam.enabled=true" )
BIN_ARGS_I2PD+=( "--sam.address=0.0.0.0" )
BIN_ARGS_I2PD+=( "--sam.port=${STACK_I2PD_PORT}" )
BIN_ARGS_I2PD+=( "--loglevel=error" )

# Exporting the generated command to the compose file.
export APP_I2PD_COMMAND=$(echo "${BIN_ARGS_I2PD[@]}")

# Runs the 'tor' and 'i2pd' containers.
echo -e " > ${CINFO}Running tor and i2pd containers...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-tor.yml up --detach tor i2pd
echo -e " > ${CSUCCESS}Containers launched!${COFF}"

# Set variables to generated tor hostname files.
TOR_RPC_SERVICE="./volumes/tor/data/app-bitcoin-rpc/hostname"
TOR_P2P_SERVICE="./volumes/tor/data/app-bitcoin-p2p/hostname"
TOR_ELECTRS_SERVICE="./volumes/tor/data/app-electrs-rpc/hostname"
export TOR_MEMPOOL_SERVICE="./volumes/tor/data/app-mempool-rpc/hostname"
export TOR_LIGHTNING_REST_SERVICE="./volumes/tor/data/app-lightning-rest/hostname"
export TOR_LIGHTNING_GRPC_SERVICE="./volumes/tor/data/app-lightning-grpc/hostname"

# Display the generated tor hostnames. Known to break due to permission errors.
for attempt in $(seq 1 100); do
	if [[ -f "${TOR_RPC_SERVICE}" ]]; then
		echo -e " > ${CINFO}Fetching generated tor addresses...${COFF}"
		echo -e " >> ${CINFO}Your bitcoin node's Tor RPC address:${COFF}" $(cat "${TOR_RPC_SERVICE}")
		echo -e " >> ${CINFO}Your bitcoin node's Tor P2P address:${COFF}" $(cat "${TOR_P2P_SERVICE}")
		echo -e " >> ${CINFO}Your electrum server's Tor address:${COFF}" $(cat "${TOR_ELECTRS_SERVICE}")
		echo -e " >> ${CINFO}Your mempool explorer's Tor address:${COFF}" $(cat "${TOR_MEMPOOL_SERVICE}")
		echo -e " >> ${CINFO}Your lightning nodes's Tor REST address:${COFF}" $(cat "${TOR_LIGHTNING_REST_SERVICE}")
		echo -e " >> ${CINFO}Your lightning nodes's Tor GRPC address:${COFF}" $(cat "${TOR_LIGHTNING_GRPC_SERVICE}")
		chmod -R 700 "./volumes/tor/data"
		break
	elif [[ "${INIT_LAUNCH}" == "True" ]]; then
		echo -e " > ${CERROR}Cannot read the new tor hostname files.${COFF}"
		echo -e " > ${CERROR}Stopping partially up docker containers...${COFF}"	
		bash "./stop.sh" > /dev/null
		echo -e " > ${CERROR}Docker containers have been stopped!${COFF}"
		echo -e " > ${CERROR}Restarting script file again.${COFF}"
		echo " ~~~~~"
		bash "start.sh"
		break
	else
		echo -e " > ${CERROR}Unable to read tor hostname files. Check permissions and run script again.${COFF}"
		echo -e " > ${CERROR}Stopping partially up docker containers...${COFF}"	
		bash "./stop.sh" > /dev/null
		echo -e " > ${CERROR}Docker containers have been stopped!${COFF}"
		exit 1
	fi
	sleep 0.1
done

# Generate and hashing bitcoin node password / auth details.
echo -e " > ${CINFO}Generating bitcoin node details...${COFF}"
BITCOIN_RPC_USERNAME="${STACK_BITCOIND_USERNAME}"

if [[ ${STACK_BITCOIND_PASSWORD} == "" ]]; then
	BITCOIN_RPC_DETAILS=$("./scripts/rpcauth.py" "${BITCOIN_RPC_USERNAME}")
	BITCOIN_RPC_PASSWORD=$(echo -e "$BITCOIN_RPC_DETAILS" | tail -1)
else
	BITCOIN_RPC_DETAILS=$("./scripts/rpcauth.py" "${BITCOIN_RPC_USERNAME}" "${STACK_BITCOIND_PASSWORD}")
	BITCOIN_RPC_PASSWORD="${STACK_BITCOIND_PASSWORD}"
fi

BITCOIN_RPC_AUTH=$(echo -e "$BITCOIN_RPC_DETAILS" | head -2 | tail -1 | sed -e "s/^rpcauth=//")
echo -e " > ${CSUCCESS}Bitcoin node details generated successfully!${COFF}"
echo -e " >> ${CINFO}Your node's Username:${COFF} ${BITCOIN_RPC_USERNAME}"
echo -e " >> ${CINFO}Your node's Password (hashed):${COFF} ${BITCOIN_RPC_PASSWORD}"
echo -e " >> ${CINFO}Your node's full Auth details:${COFF} ${BITCOIN_RPC_AUTH}"

# Exporting bitcoin node username and password to compose files.
export APP_BITCOIN_RPC_USERNAME="${BITCOIN_RPC_USERNAME}"
export APP_BITCOIN_RPC_PASSWORD="${BITCOIN_RPC_PASSWORD}"

# Generating command arguments for bitcoind container.
BIN_ARGS_BITCOIND=()
BIN_ARGS_BITCOIND+=( "-port=${STACK_BITCOIND_P2P_PORT}" )
BIN_ARGS_BITCOIND+=( "-rpcport=${STACK_BITCOIND_RPC_PORT}" )
BIN_ARGS_BITCOIND+=( "-rpcbind=${STACK_BITCOIND_IP}" )
BIN_ARGS_BITCOIND+=( "-rpcbind=0.0.0.0" )
BIN_ARGS_BITCOIND+=( "-rpcallowip=${STACK_NETWORK_SUBNET}" )
BIN_ARGS_BITCOIND+=( "-rpcallowip=0.0.0.0" )
BIN_ARGS_BITCOIND+=( "-rpcauth=\"${BITCOIN_RPC_AUTH}\"" )
BIN_ARGS_BITCOIND+=( "-zmqpubrawblock=tcp://0.0.0.0:${STACK_BITCOIND_PUB_RAW_BLOCK_PORT}" )
BIN_ARGS_BITCOIND+=( "-zmqpubrawtx=tcp://0.0.0.0:${STACK_BITCOIND_PUB_RAW_TX_PORT}" )
BIN_ARGS_BITCOIND+=( "-zmqpubhashblock=tcp://0.0.0.0:28334" )
BIN_ARGS_BITCOIND+=( "-zmqpubsequence=tcp://0.0.0.0:28335" )
BIN_ARGS_BITCOIND+=( "-deprecatedrpc=create_bd" )
BIN_ARGS_BITCOIND+=( "-deprecatedrpc=warnings" )

# Exporting the generated command to the compose file.
export APP_BITCOIN_COMMAND=$(IFS=" "; echo -e "${BIN_ARGS_BITCOIND[@]}" | tr -d '"')

# Exporting generated tor hostnames to the compose files.
export APP_BITCOIN_RPC_HIDDEN_SERVICE="$(cat "${TOR_RPC_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_BITCOIN_P2P_HIDDEN_SERVICE="$(cat "${TOR_P2P_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_ELECTRS_RPC_HIDDEN_SERVICE="$(cat "${TOR_ELECTRS_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_MEMPOOL_HIDDEN_SERVICE="$(cat "${TOR_MEMPOOL_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_LIGHTNING_REST_SERVICE="$(cat "${TOR_LIGHTNING_REST_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_LIGHTNING_RPC_SERVICE="$(cat "${TOR_LIGHTNING_RPC_SERVICE}" 2>/dev/null || echo "notyetset.onion")"

# Updating the electrs.toml file with the hashed auth details as a cookie is not generated by bitcoind.
echo -e " > ${CINFO}Updating the electrs.toml file with auth details...${COFF}"
echo "auth=\"${BITCOIN_RPC_USERNAME}:${BITCOIN_RPC_PASSWORD}\"" | tee ./volumes/electrs/electrs.toml > /dev/null
echo -e " > ${CSUCCESS}The electrs.toml file has been updated!${COFF}"

# Runs the 'bitcoind' and 'bitcoin_gui' containers.
echo -e " > ${CINFO}Running bitcoind and bitcoin_gui containers...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-bitcoin.yml up --detach bitcoind bitcoin_gui
echo -e " > ${CSUCCESS}Containers launched!${COFF}"
if ( ! docker logs bitcoin_gui > /dev/null); then
	echo -e " > ${CERROR}Bitcoin Node UI is not running due to an error.${COFF}"
	exit 1
else
	echo -e " > ${CINFO}Bitcoin Node UI is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_BITCOIN_GUI_PORT} ${COFF}"
fi

# Runs the 'electrs', 'electrs_gui' and 'explorer' containers.
echo -e " > ${CINFO}Running electrs electrs_gui and explorer containers...${COFF}"
if [[ ${STACK_RUN_MEMPOOL_SPACE} == "False" ]]; then
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-electrs.yml up --detach electrs electrs_gui btc_explorer
else
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-electrs.yml up --detach electrs electrs_gui mempool_space_web mempool_space_api mempool_space_db
fi
echo -e " > ${CSUCCESS}Containers launched!${COFF}"

# Checks if 'electrs_gui' is running.
if ( ! docker logs electrs_gui > /dev/null); then
	echo -e " > ${CERROR}Electrum Server UI is not running due to an error.${COFF}"
	exit 1
else
	echo -e " > ${CINFO}Electrum Server UI is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_ELECTRS_GUI_PORT} ${COFF}"
fi

if [[ ${STACK_RUN_MEMPOOL_SPACE} == "False" ]]; then
	if ( ! docker logs btc_explorer > /dev/null); then
		echo -e " > ${CERROR}BTC RPC Explorer is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}BTC RPC Explorer is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_MEMPOOL_PORT} ${COFF}"
	fi
else 
	if ( ! docker logs mempool_space_web > /dev/null); then
		echo -e " > ${CERROR}Mempool Space Explorer is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}Mempool Space Explorer is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_MEMPOOL_PORT} ${COFF}"
	fi
fi

# Runs the lightning container stack if toggled active.
if [[ ${STACK_RUN_LIGHTNING_SERVER} == "True" ]]; then

	# Generates command arguments for the lnd container.
	BIN_ARGS_LND=()
	BIN_ARGS_LND+=( "--configfile=/data/.lnd/umbrel-lnd.conf" )
	BIN_ARGS_LND+=( "--listen=0.0.0.0:${STACK_LIGHTNING_NODE_PORT}" )
	BIN_ARGS_LND+=( "--rpclisten=0.0.0.0:${STACK_LIGHTNING_NODE_GRPC_PORT}" )
	BIN_ARGS_LND+=( "--restlisten=0.0.0.0:${STACK_LIGHTNING_NODE_REST_PORT}" )
	BIN_ARGS_LND+=( "--bitcoin.active" )
	BIN_ARGS_LND+=( "--bitcoin.${STACK_CRYPTO_NETWORK}" )
	BIN_ARGS_LND+=( "--bitcoin.node=bitcoind" )
	BIN_ARGS_LND+=( "--bitcoind.rpchost=${STACK_BITCOIND_IP}:${STACK_BITCOIND_RPC_PORT}" )
	BIN_ARGS_LND+=( "--bitcoind.rpcuser=${BITCOIN_RPC_USERNAME}" )
	BIN_ARGS_LND+=( "--bitcoind.rpcpass=${BITCOIN_RPC_PASSWORD}" )
	BIN_ARGS_LND+=( "--bitcoind.zmqpubrawblock=tcp://${STACK_BITCOIND_IP}:${STACK_BITCOIND_PUB_RAW_BLOCK_PORT}" )
	BIN_ARGS_LND+=( "--bitcoind.zmqpubrawtx=tcp://${STACK_BITCOIND_IP}:${STACK_BITCOIND_PUB_RAW_TX_PORT}" )
	BIN_ARGS_LND+=( "--tor.active" )
	BIN_ARGS_LND+=( "--tor.v3" )
	BIN_ARGS_LND+=( "--tor.control=${APP_TOR_IP}:${APP_TOR_CONTROL_PORT}" )
	BIN_ARGS_LND+=( "--tor.socks=${APP_TOR_IP}:${APP_TOR_SOCKS_PORT}" )
	BIN_ARGS_LND+=( "--tor.targetipaddress=${APP_LIGHTNING_NODE_IP}" )
	BIN_ARGS_LND+=( "--tor.password=${APP_TOR_HASHED_PASSWORD}" )

	# Generated command is exported to the compose file.
	export APP_LIGHTNING_COMMAND=$(IFS=" "; echo "${BIN_ARGS_LND[@]}")

	# Runs the 'lnd' and 'lnd_gui' containers.
	echo -e " > ${CINFO}Running lnd and lnd_gui containers...${COFF}"
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-lightning.yml up --detach lnd lnd_gui
	echo -e " > ${CSUCCESS}Containers launched!${COFF}"

	# Checks if 'lnd_gui' is running.
	if ( ! docker logs lnd_gui > /dev/null); then
		echo -e " > ${CERROR}Lightning Node UI is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}Lightning Node UI is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_LIGHTNING_GUI_PORT} ${COFF}"
	fi
else
	echo -e " > ${CWARN}Lightning server disabled! Toggle in script or use the command line argument.${COFF}"
fi

# Runs the extras container stack if toggled active.
if [[ ${STACK_RUN_EXTRA_ORDINALS} == "True" ]]; then

	# Runs the 'ordinals' container.
	echo -e " > ${CINFO}Running ordinals container...${COFF}"
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-extras.yml up --detach ordinals
	echo -e " > ${CSUCCESS}Container launched!${COFF}"

	# Checks if 'ordinals' is running.
	if ( ! docker logs ordinals > /dev/null); then
		echo -e " > ${CERROR}Ordinals is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}Ordinals is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_EXTRAS_ORDINALS_PORT} ${COFF}"
	fi

fi

if [[ ${STACK_RUN_EXTRA_ADGUARD} == "True" ]]; then

	# Runs the 'adguard' container.
	echo -e " > ${CINFO}Running adguard container...${COFF}"
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-extras.yml up --detach adguard
	echo -e " > ${CSUCCESS}Container launched!${COFF}"

	# Checks if 'adguard' is running.
	if ( ! docker logs adguard > /dev/null); then
		echo -e " > ${CERROR}Adguard is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}Adguard is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_EXTRAS_ADGUARD_PORT} ${COFF}"
	fi

fi

if [[ ${STACK_RUN_EXTRA_NOSTR_WALLET_CONNECT} == "True" ]]; then

	# Runs the 'nostr_wallet_connect' container.
	echo -e " > ${CINFO}Running nostr_wallet_connect container...${COFF}"
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-extras.yml up --detach nostr_wallet_connect
	echo -e " > ${CSUCCESS}Container launched!${COFF}"

	# Checks if 'nostr_wallet_connect' is running.
	if ( ! docker logs adguard > /dev/null); then
		echo -e " > ${CERROR}Nostr Wallet Connect is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}Nostr Wallet Connect is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_EXTRAS_NOSTR_WALLET_CONNECT_PORT} ${COFF}"
	fi

fi

if [[ ${STACK_RUN_EXTRA_BACK_THAT_MAC} == "True" ]]; then

	# Runs the 'back_that_mac' and 'timemachine' containers.
	echo -e " > ${CINFO}Running back_that_mac and timemachine containers...${COFF}"
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-extras.yml up --detach back_that_mac timemachine
	echo -e " > ${CSUCCESS}Containers launched!${COFF}"

	# Checks if 'back_that_mac' is running.
	if ( ! docker logs back_that_mac > /dev/null); then
		echo -e " > ${CERROR}Back That Mac is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}Back That Mac is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_EXTRAS_BACK_THAT_MAC_PORT} ${COFF}"
	fi

fi

if [[ ${STACK_RUN_EXTRA_LLAMA_GPT} == "True" ]]; then

	# Runs the 'llama_gpt_api' and 'llama_gpt_ui' containers.
	echo -e " > ${CINFO}Running llama_gpt_api and llama_gpt_ui containers...${COFF}"
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-extras.yml up --detach llama_gpt_api llama_gpt_ui
	echo -e " > ${CSUCCESS}Containers launched!${COFF}"

	# Checks if 'llama_gpt_ui' is running.
	if ( ! docker logs llama_gpt_ui > /dev/null); then
		echo -e " > ${CERROR}Llama GPT is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}Llama GPT is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_EXTRAS_LLAMA_GPT_UI_PORT} ${COFF}"
	fi

fi

if [[ ${STACK_RUN_EXTRA_LIGHTNING_TERMINAL} == "True" ]]; then

	# Runs the 'lightning_terminal' container.
	echo -e " > ${CINFO}Running lightning_terminal container...${COFF}"
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-extras.yml up --detach lightning_terminal
	echo -e " > ${CSUCCESS}Container launched!${COFF}"

	# Checks if 'lightning_terminal' is running.
	if ( ! docker logs lightning_terminal > /dev/null); then
		echo -e " > ${CERROR}Lightning Terminal is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}Lightning Terminal is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_EXTRAS_LIGHTNING_TERMINAL_PORT} ${COFF}"
	fi

fi

if [[ ${STACK_RUN_EXTRA_MYSPEED} == "True" ]]; then

	# Runs the 'myspeed' container.
	echo -e " > ${CINFO}Running myspeed container...${COFF}"
	docker-compose --log-level ERROR -p crypto --file ./compose/docker-extras.yml up --detach myspeed
	echo -e " > ${CSUCCESS}Container launched!${COFF}"

	# Checks if 'myspeed' is running.
	if ( ! docker logs myspeed > /dev/null); then
		echo -e " > ${CERROR}My Speed is not running due to an error.${COFF}"
		exit 1
	else
		echo -e " > ${CINFO}My Speed is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_EXTRAS_MYSPEED_PORT} ${COFF}"
	fi

fi
