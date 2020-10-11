#!/bin/bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "${REPO}" ]; then
  echo "Error: must set env variable REPO"
  exit 1
fi

if [ -z "${TAG}" ]; then
  timestamp=$(date +%s)
  export TAG="build.$timestamp"
fi

$DIR/../src/ui/scripts/push.sh
$DIR/../src/catalog/scripts/push.sh
$DIR/../src/cart/scripts/push.sh
$DIR/../src/orders/scripts/push.sh
$DIR/../src/checkout/scripts/push.sh
$DIR/../src/assets/scripts/push.sh