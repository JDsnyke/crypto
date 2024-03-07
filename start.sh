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

# Identify script version using argument --version.
if [[ ${#@} -ne 0 ]] && [[ "${@#"--version"}" = "" ]]; then
	echo -e " > ${CINFO}Current version is v.1.1.0.${COFF}"
	exit 0
fi

# Toggle optional script features.
STACK_CHECK_UPDATES="False" ## Check for system updates using APT.
STACK_SET_PERMISSIONS="True" ## Set permissions for other script files at launch. Best turned off after initial run.

# Allocated container IP. Change this if needed, as per your preference.
STACK_NETWORK_SUBNET="10.21.0.0/16"
STACK_TOR_IP="10.21.22.1"
STACK_I2PD_IP="10.21.22.2"
STACK_BITCOIND_IP="10.21.22.3"
STACK_BITCOIN_GUI_IP="10.21.22.4"
STACK_ELECTRS_IP="10.21.22.5"
STACK_ELECTRS_GUI_IP="10.21.22.6"
STACK_MEMPOOL_IP="10.21.22.7"

# Allocated container port. Change this if needed, as per your preference.
STACK_TOR_SOCKS_PORT="9050"
STACK_TOR_CONTROL_PORT="9051"
STACK_I2PD_PORT="7656"
STACK_BITCOIND_RPC_PORT="8332"
STACK_BITCOIND_P2P_PORT="8333"
STACK_BITCOIND_TOR_PORT="8334"
STACK_ELECTRS_PORT="50001"
STACK_BITCOIN_GUI_PORT="3005"
STACK_ELECTRS_GUI_PORT="3006"
STACK_MEMPOOL_PORT="3007"

# Allocated sensitive container variables. Change this if needed, as per your preference.
STACK_BITCOIND_USERNAME="user"
STACK_TOR_PASSWORD="moneyprintergobrrr"

if [[ ${STACK_CHECK_UPDATES} == "True" ]]; then
	echo -e " > ${CINFO}Checking system updates...${COFF}"
	sudo apt update
	sudo apt upgrade -y
	echo -e " > ${CSUCCESS}System update check completed!${COFF}"
else
	echo -e " > ${CWARN}System update check skipped!${COFF}"
fi

if [[ ${STACK_SET_PERMISSIONS} == "True" ]]; then
	echo -e " > ${CINFO}Setting file permissions...${COFF}"
	chmod u+x "./stop.sh"
	chmod u+x "./scripts/rpcauth.py"
	chmod u+x "./scripts/torauth.py"
	echo -e " > ${CSUCCESS}Setting file permissions completed!${COFF}"
else
	echo -e " > ${CWARN}Setting file permissions skipped!${COFF}"
fi

if ( ! docker stats --no-stream > /dev/null); then
	echo -e " > ${CERROR}Docker is not running. Please double check and try again.${COFF}"
	exit 1
fi

# Variables exported to the docker compose files. Leave as is.
export COMPOSE_IGNORE_ORPHANS="True"
export APP_NETWORK_SUBNET="${STACK_NETWORK_SUBNET}"
export APP_TOR_PROXY_PASSWORD="${STACK_TOR_PASSWORD}"
export APP_TOR_IP="${STACK_TOR_IP}"
export APP_I2PD_IP="${STACK_I2PD_IP}"
export APP_BITCOIND_IP="${STACK_BITCOIND_IP}"
export APP_BITCOIN_GUI_IP="${STACK_BITCOIN_GUI_IP}"
export APP_ELECTRS_IP="${STACK_ELECTRS_IP}"
export APP_ELECTRS_GUI_IP="${STACK_ELECTRS_GUI_IP}"
export APP_MEMPOOL_IP="${STACK_MEMPOOL_IP}"
export APP_TOR_SOCKS_PORT="${STACK_TOR_SOCKS_PORT}"
export APP_TOR_CONTROL_PORT="${STACK_TOR_CONTROL_PORT}"
export APP_I2PD_PORT="${STACK_I2PD_PORT}"
export APP_BITCOIND_RPC_PORT="${STACK_BITCOIND_RPC_PORT}"
export APP_BITCOIND_P2P_PORT="${STACK_BITCOIND_P2P_PORT}"
export APP_ELECTRS_PORT="${STACK_ELECTRS_PORT}"
export APP_BITCOIN_GUI_PORT="${STACK_BITCOIN_GUI_PORT}"
export APP_ELECTRS_GUI_PORT="${STACK_ELECTRS_GUI_PORT}"
export APP_MEMPOOL_PORT="${STACK_MEMPOOL_PORT}"

echo -e " > ${CINFO}Pulling docker containers...${COFF}"
docker-compose --log-level ERROR --file ./compose/docker-tor.yml --file ./compose/docker-bitcoin.yml --file ./compose/docker-electrs.yml pull
echo -e " > ${CSUCCESS}Docker containers have been pulled as needed!${COFF}"

echo -e " > ${CINFO}Hashing tor password...${COFF}"
TOR_HASHED_PASSWORD=$("./scripts/torauth.py")
echo -e " > ${CSUCCESS}Password has been hashed!${COFF}"

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
HiddenServicePort ${STACK_MEMPOOL_PORT} ${STACK_MEMPOOL_IP}:${STACK_MEMPOOL_PORT}\
" | tee ./volumes/tor/torrc/torrc > /dev/null
echo -e " > ${CSUCCESS}The torrc file has been updated!${COFF}"

echo -e " > ${CINFO}Running tor and i2pd containers...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-tor.yml up --detach tor i2pd
echo -e " > ${CSUCCESS}Containers launched!${COFF}"

TOR_RPC_SERVICE="./volumes/tor/data/app-bitcoin-rpc/hostname"
TOR_P2P_SERVICE="./volumes/tor/data/app-bitcoin-p2p/hostname"
TOR_ELECTRS_SERVICE="./volumes/tor/data/app-electrs-rpc/hostname"
TOR_MEMPOOL_SERVICE="./volumes/tor/data/app-mempool-rpc/hostname"

echo -e " > ${CINFO}Fetching generated tor addresses...${COFF}"
for attempt in $(seq 1 100); do
	if [[ -f "${TOR_RPC_SERVICE}" ]]; then
		echo -e " >> ${CINFO}Your node's Tor RPC address:${COFF}" $(cat "${TOR_RPC_SERVICE}")
		echo -e " >> ${CINFO}Your node's Tor P2P address:${COFF}" $(cat "${TOR_P2P_SERVICE}")
		echo -e " >> ${CINFO}Your electrum server's Tor address:${COFF}" $(cat "${TOR_ELECTRS_SERVICE}")
		echo -e " >> ${CINFO}Your mempool explorer's Tor address:${COFF}" $(cat "${TOR_MEMPOOL_SERVICE}")
		chmod -R 700 "./volumes/tor/data"
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

echo -e " > ${CINFO}Generating bitcoin node details...${COFF}"
BITCOIN_RPC_USERNAME="${STACK_BITCOIND_USERNAME}"
BITCOIN_RPC_DETAILS=$("./scripts/rpcauth.py" "${BITCOIN_RPC_USERNAME}")
BITCOIN_RPC_PASSWORD=$(echo -e "$BITCOIN_RPC_DETAILS" | tail -1)
BITCOIN_RPC_AUTH=$(echo -e "$BITCOIN_RPC_DETAILS" | head -2 | tail -1 | sed -e "s/^rpcauth=//")
echo -e " > ${CSUCCESS}Bitcoin node details generated successfully!${COFF}"
echo -e " >> ${CINFO}Your node's Username:${COFF} ${BITCOIN_RPC_USERNAME}"
echo -e " >> ${CINFO}Your node's Password (hashed):${COFF} ${BITCOIN_RPC_PASSWORD}"
echo -e " >> ${CINFO}Your node's full Auth details:${COFF} ${BITCOIN_RPC_AUTH}"

export APP_BITCOIN_RPC_USERNAME="${BITCOIN_RPC_USERNAME}"
export APP_BITCOIN_RPC_PASSWORD="${BITCOIN_RPC_PASSWORD}"

BIN_ARGS_BITCOIND=()
BIN_ARGS_BITCOIND+=( "-port=${STACK_BITCOIND_P2P_PORT}" )
BIN_ARGS_BITCOIND+=( "-rpcport=${STACK_BITCOIND_RPC_PORT}" )
BIN_ARGS_BITCOIND+=( "-rpcbind=${STACK_BITCOIND_IP}" )
BIN_ARGS_BITCOIND+=( "-rpcbind=127.0.0.1" )
BIN_ARGS_BITCOIND+=( "-rpcallowip=${STACK_NETWORK_SUBNET}" )
BIN_ARGS_BITCOIND+=( "-rpcallowip=127.0.0.1" )
BIN_ARGS_BITCOIND+=( "-rpcauth=\"${BITCOIN_RPC_AUTH}\"" )
BIN_ARGS_BITCOIND+=( "-zmqpubrawblock=tcp://0.0.0.0:28332" )
BIN_ARGS_BITCOIND+=( "-zmqpubrawtx=tcp://0.0.0.0:28333" )
BIN_ARGS_BITCOIND+=( "-zmqpubhashblock=tcp://0.0.0.0:28334" )
BIN_ARGS_BITCOIND+=( "-zmqpubsequence=tcp://0.0.0.0:28335" )

export APP_BITCOIN_COMMAND=$(IFS=" "; echo -e "${BIN_ARGS_BITCOIND[@]}" | tr -d '"')

export DEVICE_DOMAIN_NAME=$HOSTNAME
export APP_BITCOIN_RPC_HIDDEN_SERVICE="$(cat "${TOR_RPC_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_BITCOIN_P2P_HIDDEN_SERVICE="$(cat "${TOR_P2P_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_ELECTRS_RPC_HIDDEN_SERVICE="$(cat "${TOR_ELECTRS_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_MEMPOOL_HIDDEN_SERVICE="$(cat "${TOR_MEMPOOL_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_LIGHTNING_REST_SERVICE="$(cat "${TOR_LIGHTNING_REST_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_LIGHTNING_RPC_SERVICE="$(cat "${TOR_LIGHTNING_RPC_SERVICE}" 2>/dev/null || echo "notyetset.onion")"

echo -e " > ${CINFO}Updating the electrs.toml file with auth details...${COFF}"
echo "auth=\"${BITCOIN_RPC_USERNAME}:${BITCOIN_RPC_PASSWORD}\"" | tee ./volumes/electrs/electrs.toml > /dev/null
echo -e " > ${CSUCCESS}The electrs.toml file has been updated!${COFF}"

echo -e " > ${CINFO}Running bitcoind and bitcoin_gui containers...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-bitcoin.yml up --detach bitcoind bitcoin_gui
echo -e " > ${CSUCCESS}Containers launched!${COFF}"
echo -e " > ${CINFO}Bitcoin Node UI is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_BITCOIN_GUI_PORT} ${COFF}"
echo -e " > ${CINFO}Running electrs electrs_gui and explorer containers...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-electrs.yml up --detach electrs electrs_gui explorer
echo -e " > ${CSUCCESS}Containers launched!${COFF}"
echo -e " > ${CINFO}Electrum Server UI is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_ELECTRS_GUI_PORT} ${COFF}"
echo -e " > ${CINFO}Mempool Explorer is running on${COFF}${CLINK} http://${DEVICE_DOMAIN_NAME}:${STACK_MEMPOOL_PORT} ${COFF}"