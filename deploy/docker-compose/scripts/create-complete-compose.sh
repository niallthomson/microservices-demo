#!/bin/bash

set -e

DIR=$(dirname "$0")

$DIR/generate-compose.sh $@ > $DIR/../docker-compose.yml