#!/usr/bin/env bash

echo " > Stopping docker container stack..."
docker-compose -p crypto --file ./compose/docker-tor.yml --file ./compose/docker-bitcoin.yml --file ./compose/docker-electrs.yml --file ./compose/docker-extras.yml down
