#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")
CODE_DIR=$(cd $SCRIPT_DIR/..; pwd)

if [ -z "$TAG" ]; then
  TAG="latest"
fi

if [ -z "$REPO" ]; then
  REPO="watchn"
fi

docker build -f $CODE_DIR/../../images/java11/Dockerfile --build-arg JAR_PATH=target/carts-0.0.1-SNAPSHOT.jar \
  -t $REPO/watchn-cart:$TAG $CODE_DIR
