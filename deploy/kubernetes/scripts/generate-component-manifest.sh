#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

APP_SRC_DIR="$DIR/../../.."

if [ -z "${COMPONENT}" ]; then
  echo "Error: must set env variable COMPONENT"
  exit 1
fi

if [ -z "${REPO}" ]; then
  echo "Error: must set env variable REPO"
  exit 1
fi

COMPONENT_SRC_DIR="$APP_SRC_DIR/src/$COMPONENT"

cd $COMPONENT_SRC_DIR

yaml=$(ytt -f $DIR/../src/core/values.yml \
    --data-value image.build.path=$APP_SRC_DIR/images \
    -f $COMPONENT_SRC_DIR/manifests/core \
    --data-value image.repository=$REPO \
     $@)

echo "$yaml" | kbld -f -