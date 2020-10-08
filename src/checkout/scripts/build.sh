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

docker build -f $CODE_DIR/../../images/nodejs/Dockerfile \
  -t $REPO/watchn-checkout:$TAG $CODE_DIR