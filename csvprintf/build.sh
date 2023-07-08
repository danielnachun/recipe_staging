#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export LDFLAGS="-liconv"
./autogen.sh
./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
