#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

autoreconf --install
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
