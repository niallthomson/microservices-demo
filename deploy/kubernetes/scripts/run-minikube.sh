#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/generate-manifest.sh --data-value image.push=true --data-value ui.ingress.enabled=true | kubectl apply -f -