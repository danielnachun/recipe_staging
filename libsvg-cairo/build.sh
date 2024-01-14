#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

autoreconf --force --install --verbose
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install LIBTOOL=${PREFIX}/bin/libtool
