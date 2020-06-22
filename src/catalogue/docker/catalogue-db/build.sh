#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")

if [ -z "$TAG" ]; then
  TAG="latest"
fi

if [ -z "$REPO" ]; then
  REPO="microservices-demo"
fi

docker build -f $SCRIPT_DIR/Dockerfile \
  -t $REPO/shop-catalogue-db:$TAG $SCRIPT_DIR