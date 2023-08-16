#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="-Wno-int-conversion"
./configure --disable-debug \
    --disable-silent \
    --disable-dependency-tracking \
    --enable-shared \
    --prefix=${PREFIX} 
make
make check
make install
