#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export LIBS="-liconv"
./autogen.sh
./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
