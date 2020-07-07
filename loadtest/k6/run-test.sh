#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

base_url=$1

if [ -z "$base_url" ]; then
  echo "Error: Not base URL specified - ./run-test.sh <baseurl>"
  exit 1
fi

cd $DIR

docker-compose run -v \
    $PWD/scripts:/scripts \
    -e WATCHN_BASE_URL=$base_url \
    k6 run /scripts/script.js