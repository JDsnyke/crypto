#!/usr/bin/env bash

echo " > System update check"
sudo apt update
sudo apt upgrade -y

if ( ! docker stats --no-stream &> /dev/null); then
	echo " > Docker is not running. Please double check and try again."
	exit
fi

ARCH=$(uname -m)
SSL_PROXY_FILE="./scripts/ssl-proxy"

if [[ ! -f "${SSL_PROXY_FILE}" ]]; then
	echo " > Setting up ssl-proxy"
	git clone https://github.com/JDsnyke/ssl-proxy.git
	echo " > Building ssl-proxy"
	docker-compose --file "./ssl-proxy/docker-compose.build.yml" build
	docker-compose --file "./ssl-proxy/docker-compose.build.yml" up
	docker-compose --file "./ssl-proxy/docker-compose.build.yml" down
	cp "./build/ssl-proxy-linux-${ARCH}" "./scripts"
	mv "./scripts/ssl-proxy-linux-${ARCH}" "./scripts/ssl-proxy"
	sudo rm -r "./build"
	sudo rm -r "./ssl-proxy"
fi

chmod u+x "./stop.sh"
chmod u+x "./scripts/rpcauth.py"
chmod u+x "./scripts/pihole.sh"
chmod u+x "./scripts/ssl-proxy"

echo " > Pulling docker containers"
docker-compose --file docker-tor.yml --file docker-bitcoin.yml --file docker-electrs.yml --file docker-extras.yml pull

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

docker-compose -p crypto --file docker-tor.yml up --detach tor i2pd

TOR_RPC_SERVICE="./tor/data/app-bitcoin-rpc/hostname"
TOR_P2P_SERVICE="./tor/data/app-bitcoin-p2p/hostname"
TOR_ELECTRS_SERVICE="./tor/data/app-electrs-rpc/hostname"
TOR_MEMPOOL_SERVICE="./tor/data/app-mempool-rpc/hostname"
TOR_LIGHTNING_REST_SERVICE="./tor/data/app-lightning-rest/hostname"
TOR_LIGHTNING_RPC_SERVICE="./tor/data/app-lightning-grpc/hostname"

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
# BIN_ARGS_BITCOIND+=( "-blockfilterindex=1" )
# BIN_ARGS_BITCOIND+=( "-peerbloomfilters=1" )
# BIN_ARGS_BITCOIND+=( "-peerblockfilters=1" )
# BIN_ARGS_BITCOIND+=( "-rpcworkqueue=128" )

export APP_BITCOIN_COMMAND=$(IFS=" "; echo "${BIN_ARGS_BITCOIND[@]}" | tr -d '"')

export DEVICE_DOMAIN_NAME=$HOSTNAME
export APP_BITCOIN_RPC_HIDDEN_SERVICE="$(cat "${TOR_RPC_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_BITCOIN_P2P_HIDDEN_SERVICE="$(cat "${TOR_P2P_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_ELECTRS_RPC_HIDDEN_SERVICE="$(cat "${TOR_ELECTRS_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_MEMPOOL_HIDDEN_SERVICE="$(cat "${TOR_MEMPOOL_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_LIGHTNING_REST_SERVICE="$(cat "${TOR_LIGHTNING_REST_SERVICE}" 2>/dev/null || echo "notyetset.onion")"
export APP_LIGHTNING_RPC_SERVICE="$(cat "${TOR_LIGHTNING_RPC_SERVICE}" 2>/dev/null || echo "notyetset.onion")"

docker-compose -p crypto --file docker-bitcoin.yml up --detach bitcoind bitcoin_gui

echo " > Bitcoin Node UI running on ${DEVICE_DOMAIN_NAME}:3005"

docker-compose -p crypto --file docker-electrs.yml up --detach electrs electrs_gui mempool mempool_api mariadb

echo " > Electrum Server UI running on ${DEVICE_DOMAIN_NAME}:3006"
echo " > Mempool Explorer running on ${DEVICE_DOMAIN_NAME}:3002"

# Enable extra containers

## ./scripts/pihole.sh # Run before installing pihole on linux systems!

## docker-compose -p crypto --file docker-extras.yml up --detach whoogle dashdot snapdrop homarr pihole tailscale

# Enable Local SSL for containers (breaks due to conflicts with pihole)

## echo " > Setting local ssl certs"
## SSL_BITCOIN=$(./scripts/ssl-proxy -from "0.0.0.0:5100" -to "0.0.0.0:3005" 2>/dev/null)
## SSL_ELECTRS=$(./scripts/ssl-proxy -from "0.0.0.0:5200" -to "0.0.0.0:3006" 2> /dev/null)
## SSL_MEMPOOL=$(./scripts/ssl-proxy -from "0.0.0.0:5300" -to "0.0.0.0:3002" 2> /dev/null)
## SSL_HOMARR=$(./scripts/ssl-proxy -from "0.0.0.0:5400" -to "0.0.0.0:7575" 2> /dev/null)
## SSL_PIHOLE=$(./scripts/ssl-proxy -from "0.0.0.0:5500" -to "0.0.0.0:8082" 2> /dev/null)
## rm cert.pem key.pem

# Tailscale cert generation (untested)

## docker exec tailscale tailscale cert xxxx.xxxx.ts.net