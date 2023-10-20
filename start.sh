#!/bin/bash

chmod u+x "./stop.sh"
chmod u+x "./scripts/rpcauth.py"
chmod u+x "./scripts/pihole.sh"

if ( ! docker stats --no-stream &> /dev/null); then
	echo " > Docker is not running. Please double check and try again."
	exit
fi

export COMPOSE_IGNORE_ORPHANS="True"
export APP_TOR_IP="10.21.22.1"
export APP_I2PD_IP="10.21.22.2"
export APP_BITCOIND_IP="10.21.22.3"
export APP_BITCOIN_GUI_IP="10.21.22.4"
export APP_ELECTRS_IP="10.21.22.5"
export APP_ELECTRS_GUI_IP="10.21.22.6"
export APP_MEMPOOL_IP="10.21.22.7"
export APP_MEMPOOL_API_IP="10.21.22.8"
export APP_MARIADB_IP="10.21.22.9"

docker compose -p crypto --file docker-tor.yml up --detach tor i2pd

TOR_RPC_SERVICE="./tor/data/app-bitcoin-rpc/hostname"
TOR_P2P_SERVICE="./tor/data/app-bitcoin-p2p/hostname"
TOR_ELECTRS_SERVICE="./tor/data/app-electrs-rpc/hostname"
TOR_MEMPOOL_SERVICE="./tor/data/app-mempool-rpc/hostname"

for attempt in $(seq 1 100); do
	if [[ -f "${TOR_RPC_SERVICE}" ]]; then
		echo " > Your node's Tor RPC address:" $(cat "${TOR_RPC_SERVICE}")
		echo " > Your node's Tor P2P address:" $(cat "${TOR_P2P_SERVICE}")
		echo " > Your electrum server's Tor address:" $(cat "${TOR_ELECTRS_SERVICE}")
		echo " > Your mempool explorer's Tor address:" $(cat "${TOR_MEMPOOL_SERVICE}")
		break
	fi
	sleep 0.1
done

BITCOIN_RPC_USERNAME="user"
BITCOIN_RPC_DETAILS=$("./scripts/rpcauth.py" "${BITCOIN_RPC_USERNAME}")
BITCOIN_RPC_PASSWORD=$(echo "$BITCOIN_RPC_DETAILS" | tail -1)
BITCOIN_RPC_AUTH=$(echo "$BITCOIN_RPC_DETAILS" | head -2 | tail -1 | sed -e "s/^rpcauth=//")

echo " > Your node's Username: ${BITCOIN_RPC_USERNAME}"
echo " > Your node's Password (hashed): ${BITCOIN_RPC_PASSWORD}"
echo " > Your node's full Auth details: ${BITCOIN_RPC_AUTH}"

export APP_BITCOIN_RPC_USERNAME="${BITCOIN_RPC_USERNAME}"
export APP_BITCOIN_RPC_PASSWORD="${BITCOIN_RPC_PASSWORD}"

BIN_ARGS=()
BIN_ARGS+=( "-port=8333" )
BIN_ARGS+=( "-rpcport=8332" )
BIN_ARGS+=( "-rpcbind=${APP_BITCOIND_IP}" )
BIN_ARGS+=( "-rpcbind=127.0.0.1" )
BIN_ARGS+=( "-rpcallowip=10.21.22.0/16" )
BIN_ARGS+=( "-rpcallowip=127.0.0.1" )
BIN_ARGS+=( "-rpcauth=\"${BITCOIN_RPC_AUTH}\"" )
BIN_ARGS+=( "-zmqpubrawblock=tcp://0.0.0.0:28332" )
BIN_ARGS+=( "-zmqpubrawtx=tcp://0.0.0.0:28333" )
BIN_ARGS+=( "-zmqpubhashblock=tcp://0.0.0.0:28334" )
BIN_ARGS+=( "-zmqpubsequence=tcp://0.0.0.0:28335" )
BIN_ARGS+=( "-blockfilterindex=1" )
BIN_ARGS+=( "-peerbloomfilters=1" )
BIN_ARGS+=( "-peerblockfilters=1" )
BIN_ARGS+=( "-rpcworkqueue=128" )

export APP_BITCOIN_COMMAND=$(IFS=" "; echo "${BIN_ARGS[@]}" | tr -d '"')

export DEVICE_DOMAIN_NAME=$HOSTNAME
export APP_BITCOIN_RPC_HIDDEN_SERVICE="$(cat "${TOR_RPC_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_BITCOIN_P2P_HIDDEN_SERVICE="$(cat "${TOR_P2P_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_ELECTRS_RPC_HIDDEN_SERVICE="$(cat "${TOR_ELECTRS_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_MEMPOOL_HIDDEN_SERVICE="$(cat "${TOR_MEMPOOL_SERVICE}" 2>/dev/null || echo "notyetset.onion")"

docker compose -p crypto --file docker-bitcoin.yml up --detach bitcoind bitcoin_gui

docker compose -p crypto --file docker-electrs.yml up --detach electrs electrs_gui mempool mempool_api mariadb

# Enable extra containers

## ./scripts/pihole.sh # Run before installing pihole on linux systems!

## docker compose -p crypto --file docker-extras.yml up --detach whoogle dashdot pihole tailscale
