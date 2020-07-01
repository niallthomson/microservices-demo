#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

outdir=$(mktemp -d)

openapi-generator generate \
  -i http://localhost:8081/swagger/doc.json \
  --api-package com.watchn.ui.clients.catalog.api \
  --model-package com.watchn.ui.clients.catalog.model \
  -g java \
  --library webclient \
  -o $outdir

if [ -d $DIR/src/main/java/com/watchn/ui/clients/catalog ]; then
  rm -rf $DIR/src/main/java/com/watchn/ui/clients/catalog
fi

(cd $outdir/src/main/java && find . -name '*.java' | cpio -pdm $DIR/src/main/java)

outdir=$(mktemp -d)

openapi-generator generate \
  -i http://localhost:8082/v2/api-docs \
  --api-package com.watchn.ui.clients.carts.api \
  --model-package com.watchn.ui.clients.carts.model \
  -g java \
  --library webclient \
  --skip-validate-spec \
  -o $outdir

if [ -d $DIR/src/main/java/com/watchn/ui/clients/carts ]; then
  rm -rf $DIR/src/main/java/com/watchn/ui/clients/carts
fi

(cd $outdir/src/main/java && find . -name '*.java' | cpio -pdm $DIR/src/main/java)