#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "${REPO}" ]; then
  echo "Error: must set env variable REPO"
  exit 1
fi

if [ -z "${TAG}" ]; then
  echo "Error: must set env variable TAG"
  exit 1
fi

$SCRIPT_DIR/push-all.sh
$SCRIPT_DIR/../deploy/docker-compose/scripts/create-complete-compose.sh --data-value imageTag=$TAG
$SCRIPT_DIR/../deploy/kubernetes/scripts/create-complete-manifest.sh --data-value imageTag=$TAG