#!/bin/bash

set -euo pipefail

url=$1

if [ -z "$url" ]; then
  echo "Error: No URL specified"
  exit 1
fi

status_code=$(curl -o /dev/null -s -w "%{http_code}\n" $url)

if [[ "$status_code" -ne 200 ]] ; then
  echo "Error: HTTP status code not 200 ($status_code)"
  exit 1
fi