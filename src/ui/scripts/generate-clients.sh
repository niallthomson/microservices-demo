#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/generate-client.sh catalog http://localhost:8081/swagger/doc.json
$DIR/generate-client.sh carts http://localhost:8082/v2/api-docs
$DIR/generate-client.sh orders http://localhost:8083/v2/api-docs