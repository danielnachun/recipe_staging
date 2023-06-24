#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="-Wno-implicit-int"
./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make LIBS="-Wl,--allow-multiple-definition"
make install
