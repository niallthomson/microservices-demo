#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/generate-manifest.sh --data-value image.tag=dummy --data-value ui.ingress.enabled=true | kubectl delete -f -