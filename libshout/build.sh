#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
