#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ "${target_platform}" == darwin-* ]]; then
    LDFLAGS="-liconv"
fi

./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
