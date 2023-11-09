#!/usr/bin/env bash

docker-compose -p crypto --file docker-tor.yml --file docker-bitcoin.yml --file docker-electrs.yml --file docker-extras.yml down
