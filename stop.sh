#!/usr/bin/env bash

# Console colors for better legibility.
COFF="\033[0m"
CINFO="\033[01;34m"
CSUCCESS="\033[0;32m"
CWARN="\033[0;33m"
CERROR="\033[0;31m"

# Toggle option to prune docker system. Helpful to clean up old and unused images, networks, etc.
STACK_DOCKER_PRUNE="False"

# Allocated container IP. Copy from the start.sh script if changed.
STACK_NETWORK_SUBNET="10.21.0.0/16"
STACK_TOR_IP="10.21.22.1"
STACK_I2PD_IP="10.21.22.2"
STACK_BITCOIND_IP="10.21.22.3"
STACK_BITCOIN_GUI_IP="10.21.22.4"
STACK_ELECTRS_IP="10.21.22.5"
STACK_ELECTRS_GUI_IP="10.21.22.6"
STACK_MEMPOOL_IP="10.21.22.7"
STACK_LIGHTNING_NODE_IP="10.21.22.8"

# Allocated container port. Copy from the start.sh script if changed.
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
STACK_LIGHTNING_NODE_REST_PORT="10009"
STACK_LIGHTNING_NODE_GRPC_PORT="8080"
STACK_BITCOIN_GUI_PORT="3005"
STACK_ELECTRS_GUI_PORT="3006"
STACK_MEMPOOL_PORT="3007"
STACK_LIGHTNING_GUI_PORT="3008"

# Script error handling.
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

# Variables exported to the docker compose files. Leave as is.
export APP_NETWORK_SUBNET="${STACK_NETWORK_SUBNET}"
export APP_TOR_IP="${STACK_TOR_IP}"
export APP_I2PD_IP="${STACK_I2PD_IP}"
export APP_BITCOIND_IP="${STACK_BITCOIND_IP}"
export APP_BITCOIN_GUI_IP="${STACK_BITCOIN_GUI_IP}"
export APP_ELECTRS_IP="${STACK_ELECTRS_IP}"
export APP_ELECTRS_GUI_IP="${STACK_ELECTRS_GUI_IP}"
export APP_MEMPOOL_IP="${STACK_MEMPOOL_IP}"
export APP_LIGHTNING_NODE_IP="${STACK_LIGHTNING_NODE_IP}"
export APP_LIGHTNING_GUI_PORT="${STACK_LIGHTNING_GUI_PORT}"
export APP_TOR_SOCKS_PORT="${STACK_TOR_SOCKS_PORT}"
export APP_TOR_CONTROL_PORT="${STACK_TOR_CONTROL_PORT}"
export APP_I2PD_PORT="${STACK_I2PD_PORT}"
export APP_BITCOIND_RPC_PORT="${STACK_BITCOIND_RPC_PORT}"
export APP_BITCOIND_P2P_PORT="${STACK_BITCOIND_P2P_PORT}"
export APP_ELECTRS_PORT="${STACK_ELECTRS_PORT}"
export APP_LIGHTNING_NODE_REST_PORT="${STACK_LIGHTNING_NODE_REST_PORT}"
export APP_LIGHTNING_NODE_PORT="${STACK_LIGHTNING_NODE_PORT}"
export APP_LIGHTNING_NODE_GRPC_PORT="${STACK_LIGHTNING_NODE_GRPC_PORT}"
export APP_BITCOIN_GUI_PORT="${STACK_BITCOIN_GUI_PORT}"
export APP_ELECTRS_GUI_PORT="${STACK_ELECTRS_GUI_PORT}"
export APP_MEMPOOL_PORT="${STACK_MEMPOOL_PORT}"
export APP_LIGHTNING_GUI_PORT="${STACK_LIGHTNING_GUI_PORT}"

echo -e " > ${CINFO}Stopping docker container stack...${COFF}"
docker-compose --log-level ERROR -p crypto --file ./compose/docker-tor.yml --file ./compose/docker-bitcoin.yml --file ./compose/docker-electrs.yml --file ./compose/docker-lightning.yml down

if [[ ${STACK_DOCKER_PRUNE} == "True" ]]; then
	echo -e " > ${CINFO}Commencing docker system prune...${COFF}"
	docker system prune -f
	echo -e " > ${CSUCCESS}Docker system prune completed!${COFF}"
else
	echo -e " > ${CWARN}Docker system prune skipped!${COFF}"
fi