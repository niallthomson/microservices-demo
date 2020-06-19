#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")

export REPO="niallthomson"
export TAG=$(date +%s)

$SCRIPT_DIR/../src/front-end/scripts/push.sh
$SCRIPT_DIR/../src/catalogue/scripts/push.sh
$SCRIPT_DIR/../src/cart/scripts/push.sh
$SCRIPT_DIR/../src/payment/scripts/push.sh
$SCRIPT_DIR/../src/orders/scripts/push.sh
$SCRIPT_DIR/../src/user/scripts/push.sh