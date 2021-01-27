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

docker build -f $CODE_DIR/Dockerfile \
  -t $REPO/watchn-e2e:$TAG $CODE_DIR