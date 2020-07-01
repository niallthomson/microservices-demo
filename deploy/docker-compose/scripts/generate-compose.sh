#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

APP_SRC_DIR="$DIR/../../.."

ytt -f $DIR/../src \
    --data-value imagePath=$APP_SRC_DIR/images \
    -f $APP_SRC_DIR/src/cart/manifests/core/images.yml \
    -f $APP_SRC_DIR/src/cart/manifests/core/values.yml \
    --data-value cart.imagePath=$APP_SRC_DIR/src/cart \
    -f $APP_SRC_DIR/src/catalog/manifests/core/images.yml \
    -f $APP_SRC_DIR/src/catalog/manifests/core/values.yml \
    --data-value catalog.imagePath=$APP_SRC_DIR/src/catalog \
    -f $APP_SRC_DIR/src/ui/manifests/core/images.yml \
    -f $APP_SRC_DIR/src/ui/manifests/core/values.yml \
    --data-value ui.imagePath=$APP_SRC_DIR/src/ui \
    -f $APP_SRC_DIR/src/orders/manifests/core/images.yml \
    -f $APP_SRC_DIR/src/orders/manifests/core/values.yml \
    --data-value orders.imagePath=$APP_SRC_DIR/src/orders $@ \
    | kbld -f - --images-annotation=false