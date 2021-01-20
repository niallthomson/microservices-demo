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

$DIR/../src/ui/scripts/build.sh
$DIR/../src/catalog/scripts/build.sh
$DIR/../src/cart/scripts/build.sh
$DIR/../src/orders/scripts/build.sh
$DIR/../src/checkout/scripts/build.sh
$DIR/../src/assets/scripts/build.sh