#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --disable-dynamic \
    --prefix=${PREFIX} 
make
make install
