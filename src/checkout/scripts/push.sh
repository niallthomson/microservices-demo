#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")

if [ -z "${REPO}" ]; then
  echo "Error: must set env variable REPO"
  exit 1
fi

if [ -z "${TAG}" ]; then
  TAG=$(date +%s)
fi

TAG=$TAG $SCRIPT_DIR/build.sh

docker push $REPO/watchn-checkout:$TAG