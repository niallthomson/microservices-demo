#!/bin/bash

set -e

DIR=$(dirname "$0")

$DIR/generate-manifest.sh $@ > $DIR/../complete.yml