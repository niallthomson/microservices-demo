#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")
CODE_DIR=$(cd $SCRIPT_DIR/..; pwd)

if [ -z "$TAG" ]; then
  TAG="latest"
fi

if [ -z "$REPO" ]; then
  REPO="microservices-demo"
fi

docker build -f $CODE_DIR/../../images/java/Dockerfile --build-arg JAR_PATH=target/orders.jar \
  -t $REPO/shop-orders:$TAG $CODE_DIR