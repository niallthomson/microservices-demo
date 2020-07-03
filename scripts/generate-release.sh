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

$DIR/push-all.sh
$DIR/../deploy/docker-compose/scripts/generate-manifest.sh --data-value imageTag=$TAG > $DIR/../deploy/docker-compose/docker-compose.yml
$DIR/../deploy/kubernetes/scripts/generate-manifest.sh --data-value imageTag=$TAG --data-value includeServices=true  > $DIR/../deploy/kubernetes/complete.yml