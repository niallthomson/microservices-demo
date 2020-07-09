#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

APP_SRC_DIR="$DIR/../../.."

if [ -z "${REPO}" ]; then
  echo "Error: must set env variable REPO"
  exit 1
fi

ytt -f $DIR/../src/core \
    --data-value image.build.path=$APP_SRC_DIR/images \
    -f $APP_SRC_DIR/src/cart/manifests/core \
    --data-value cart.image.build.path=$APP_SRC_DIR/src/cart \
    -f $APP_SRC_DIR/src/catalog/manifests/core \
    --data-value catalog.image.build.path=$APP_SRC_DIR/src/catalog \
    -f $APP_SRC_DIR/src/ui/manifests/core \
    --data-value ui.image.build.path=$APP_SRC_DIR/src/ui \
    -f $APP_SRC_DIR/src/orders/manifests/core \
    --data-value orders.image.build.path=$APP_SRC_DIR/src/orders \
    --data-value image.repository=$REPO \
     $@ | kbld -f -