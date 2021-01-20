#!/bin/bash

set -euo pipefail

output=$1

if [ -z "$output" ]; then
  echo "Error: No output path specified"
  exit 1
fi

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

cd $DIR

zip -q -r $output . -x scripts/\*