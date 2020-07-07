#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

base_url=$1
region=$2
target=$3
influx_url=$4

if [ -z "$base_url" ]; then
  echo "Error: No base URL specified - ./run-test.sh <baseurl> <region>"
  exit 1
fi

if [ -z "$region" ]; then
  echo "Error: No region specified - ./run-test.sh <baseurl> <region>"
  exit 1
fi

if [ -z "$target" ]; then
  echo "Defaulting target to 20"
  target="20"
fi

if [ -z "$influx_url" ]; then
  echo "Defaulting influx url to http://influxdb:8086/k6"
  influx_url="http://influxdb:8086/k6"
fi

cd $DIR

export WATCHN_BASE_URL=$base_url
export WATCHN_REGION=$region
export WATCHN_TARGET=$target
export WATCHN_INFLUXDB_URL="influxdb=$influx_url"

docker-compose run -v \
    $PWD/scripts:/scripts \
    k6 run /scripts/script.js