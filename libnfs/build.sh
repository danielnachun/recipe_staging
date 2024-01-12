#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./bootstrap
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
