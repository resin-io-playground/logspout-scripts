#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/utils.sh

IMAGE="resinplayground/logspout"
LOGGING_SERVER=${LOGGING_SERVER:-"syslog+tcp://logstash.resin.io:5000"}

ARCH=${ARCH:-$(listArchLabeledImages | jq '.[0].Labels."io.resin.architecture"' | tr -d '"')}
if [ -z "$ARCH" ] || [ "$ARCH" = "null" ]; then
	echo "Could not detect device architecture."
	echo "Please run this script with ARCH environment variable set to match the architecture of this device."
	exit 1
fi

echo "Detected architecture: ${ARCH}"

function showHelp {
	echo "This script is used to create and start a logspout container on the device"
	echo "It should be used locally on the device within a running app container"
	echo "Based on Docker Remote API v1.22"
	echo
	echo "Usage: $0 [action]"
	echo "Commands:"
	for command in ${DIR}/commands/*; do
		if [[ -f "${command}" ]]; then
			echo "	$(basename "${command}")"
		fi
	done
	echo "Dependencies:"
	echo "	jq >=1.5 current: $(jq --version 2>&1)"
}

if [ "$#" -eq 0 ]; then
	showHelp
	exit
fi

ACTION=$1
shift

for command in ${DIR}/commands/*; do
	if [ "$(basename "${command}")" = $ACTION ]; then
		source ${command}
		exit
	fi
done

showHelp
