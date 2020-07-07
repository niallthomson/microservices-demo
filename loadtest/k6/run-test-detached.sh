#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

base_url=$1
region=$2
target=$3

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

cd $DIR

docker-compose run -d -v \
    $PWD/scripts:/scripts \
    -e WATCHN_BASE_URL=$base_url \
    -e WATCHN_REGION=$region \
    -e WATCHN_TARGET=$target \
    k6 run /scripts/script.js