#!/usr/bin/env bash

COFF="\033[0m"
CINFO="\033[0;34m"
CSUCCESS="\033[0;32m"
CWARN="\033[0;33m"
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

if [[ ${#@} -ne 0 ]] && [[ "${@#"--version"}" = "" ]]; then
	echo " > ${CINFO}Current version is v.1.0.0.${COFF}"
	exit 0
fi

STACK_CHECK_UPDATES="False"
STACK_SET_PERMISSIONS="True"

if [[ ${STACK_CHECK_UPDATES} == "True" ]]; then
	echo " > ${CINFO}Checking system updates...${COFF}"
	sudo apt update
	sudo apt upgrade -y
	echo " > ${CSUCCESS}System update check completed!${COFF}"
else
	echo " > ${CWARN}System update check skipped!${COFF}"
fi

if [[ ${STACK_SET_PERMISSIONS} == "True" ]]; then
	echo " > ${CINFO}Setting file permissions...${COFF}"
	sudo chmod u+x "./stop.sh"
	sudo chmod u+x "./scripts/rpcauth.py"
	echo " > ${CSUCCESS}Setting file permissions completed!${COFF}"
else
	echo " > ${CWARN}Setting file permissions skipped!${COFF}"
fi

if ( ! docker stats --no-stream &> /dev/null); then
	echo " > ${CERROR}Docker is not running. Please double check and try again.${COFF}"
	exit
fi

echo " > ${CINFO}Pulling docker containers...${COFF}"
docker-compose --log-level ERROR --file ./compose/docker-tor.yml --file ./compose/docker-bitcoin.yml --file ./compose/docker-electrs.yml pull
echo " > ${CSUCCESS}Pulled required docker containers as needed!${COFF}"

export COMPOSE_IGNORE_ORPHANS="True"
export APP_TOR_IP="10.21.22.1"
export APP_I2PD_IP="10.21.22.2"
export APP_BITCOIND_IP="10.21.22.3"
export APP_BITCOIN_GUI_IP="10.21.22.4"
export APP_ELECTRS_IP="10.21.22.5"
export APP_ELECTRS_GUI_IP="10.21.22.6"
export APP_MEMPOOL_IP="10.21.22.7"

echo " > ${CINFO}Running tor and i2pd containers...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-tor.yml up --detach tor i2pd
echo " > ${CSUCCESS}Containers launched!${COFF}"

TOR_RPC_SERVICE="./compose/tor/data/app-bitcoin-rpc/hostname"
TOR_P2P_SERVICE="./compose/tor/data/app-bitcoin-p2p/hostname"
TOR_ELECTRS_SERVICE="./compose/tor/data/app-electrs-rpc/hostname"
TOR_MEMPOOL_SERVICE="./compose/tor/data/app-mempool-rpc/hostname"
TOR_LIGHTNING_REST_SERVICE="./compose/tor/data/app-lightning-rest/hostname"
TOR_LIGHTNING_RPC_SERVICE="./compose/tor/data/app-lightning-grpc/hostname"

echo " > ${CINFO}Generating tor addresses...${COFF}"
for attempt in $(seq 1 100); do
	if [[ -f "${TOR_RPC_SERVICE}" ]]; then
		echo " >> ${CINFO}Your node's Tor RPC address:${COFF}" $(cat "${TOR_RPC_SERVICE}")
		echo " >> ${CINFO}Your node's Tor P2P address:${COFF}" $(cat "${TOR_P2P_SERVICE}")
		echo " >> ${CINFO}Your electrum server's Tor address:${COFF}" $(cat "${TOR_ELECTRS_SERVICE}")
		echo " >> ${CINFO}Your mempool explorer's Tor address:${COFF}" $(cat "${TOR_MEMPOOL_SERVICE}")
		chmod -R 700 "./volumes/tor/data"
		break
	fi
	sleep 0.1
done

echo " > ${CINFO}Generating bitcoin node details...${COFF}"
BITCOIN_RPC_USERNAME="user"
BITCOIN_RPC_DETAILS=$("./scripts/rpcauth.py" "${BITCOIN_RPC_USERNAME}")
BITCOIN_RPC_PASSWORD=$(echo "$BITCOIN_RPC_DETAILS" | tail -1)
BITCOIN_RPC_AUTH=$(echo "$BITCOIN_RPC_DETAILS" | head -2 | tail -1 | sed -e "s/^rpcauth=//")

echo " >> ${CINFO}Your node's Username:${COFF} ${BITCOIN_RPC_USERNAME}"
echo " >> ${CINFO}Your node's Password (hashed):${COFF} ${BITCOIN_RPC_PASSWORD}"
echo " >> ${CINFO}Your node's full Auth details:${COFF} ${BITCOIN_RPC_AUTH}"

export APP_BITCOIN_RPC_USERNAME="${BITCOIN_RPC_USERNAME}"
export APP_BITCOIN_RPC_PASSWORD="${BITCOIN_RPC_PASSWORD}"

BIN_ARGS_BITCOIND=()
BIN_ARGS_BITCOIND+=( "-port=8333" )
BIN_ARGS_BITCOIND+=( "-rpcport=8332" )
BIN_ARGS_BITCOIND+=( "-rpcbind=${APP_BITCOIND_IP}" )
BIN_ARGS_BITCOIND+=( "-rpcbind=127.0.0.1" )
BIN_ARGS_BITCOIND+=( "-rpcallowip=10.21.22.0/16" )
BIN_ARGS_BITCOIND+=( "-rpcallowip=127.0.0.1" )
BIN_ARGS_BITCOIND+=( "-rpcauth=\"${BITCOIN_RPC_AUTH}\"" )
BIN_ARGS_BITCOIND+=( "-zmqpubrawblock=tcp://0.0.0.0:28332" )
BIN_ARGS_BITCOIND+=( "-zmqpubrawtx=tcp://0.0.0.0:28333" )
BIN_ARGS_BITCOIND+=( "-zmqpubhashblock=tcp://0.0.0.0:28334" )
BIN_ARGS_BITCOIND+=( "-zmqpubsequence=tcp://0.0.0.0:28335" )

export APP_BITCOIN_COMMAND=$(IFS=" "; echo "${BIN_ARGS_BITCOIND[@]}" | tr -d '"')

export DEVICE_DOMAIN_NAME=$HOSTNAME
export APP_BITCOIN_RPC_HIDDEN_SERVICE="$(cat "${TOR_RPC_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_BITCOIN_P2P_HIDDEN_SERVICE="$(cat "${TOR_P2P_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_ELECTRS_RPC_HIDDEN_SERVICE="$(cat "${TOR_ELECTRS_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_MEMPOOL_HIDDEN_SERVICE="$(cat "${TOR_MEMPOOL_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_LIGHTNING_REST_SERVICE="$(cat "${TOR_LIGHTNING_REST_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_LIGHTNING_RPC_SERVICE="$(cat "${TOR_LIGHTNING_RPC_SERVICE}" 2>/dev/null || echo "notyetset.onion")"

echo " > ${CINFO}Running bitcoind and bitcoin_gui containers...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-bitcoin.yml up --detach bitcoind bitcoin_gui
echo " > ${CSUCCESS}Containers launched!${COFF}"
echo " > ${CINFO}Bitcoin Node UI is running on http://${DEVICE_DOMAIN_NAME}:3005 ${COFF}"
echo " > ${CINFO}Running electrs electrs_gui mempool mempool_api and mariadb containers...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-electrs.yml up --detach electrs electrs_gui explorer
echo " > ${CSUCCESS}Containers launched!${COFF}"
echo " > ${CINFO}Electrum Server UI is running on http://${DEVICE_DOMAIN_NAME}:3006 ${COFF}"
echo " > ${CINFO}Mempool Explorer is running on http://${DEVICE_DOMAIN_NAME}:3007 ${COFF}"