#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

autoreconf --force --install --verbose

CFLAGS="-Wno-implicit-function-declaration"

./configure --disable-silent \
    --disable-nls \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
