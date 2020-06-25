#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")

if [ -z "${REPO}" ]; then
  echo "Error: must set env variable REPO"
  exit 1
fi

if [ -z "${TAG}" ]; then
  export TAG=$(date +%s)
fi

$SCRIPT_DIR/../src/front-end/scripts/push.sh
$SCRIPT_DIR/../src/catalog/scripts/push.sh
$SCRIPT_DIR/../src/cart/scripts/push.sh
$SCRIPT_DIR/../src/payment/scripts/push.sh
$SCRIPT_DIR/../src/orders/scripts/push.sh
$SCRIPT_DIR/../src/user/scripts/push.sh