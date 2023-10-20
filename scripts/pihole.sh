#!/usr/bin/env bash

set -euo pipefail

RESOLVED_SERVICE_NAME="systemd-resolved"
RESOLVED_CONF_FILE="/etc/systemd/resolved.conf"

if ! systemctl is-active --quiet service "${RESOLVED_SERVICE_NAME}"; then
	echo " > Service '${RESOLVED_SERVICE_NAME}' is not running"
	exit
fi

if cat "${RESOLVED_CONF_FILE}" | grep --quiet "^DNSStubListener=no$"; then
	echo " > DNSStubListener already turned off"
	exit
fi

echo " > Turning off the DNS Stub Listener"

sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' "${RESOLVED_CONF_FILE}"

rm -f /etc/resolv.conf

ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

echo "Restart service '${RESOLVED_SERVICE_NAME}'"
systemctl restart "${RESOLVED_SERVICE_NAME}"
