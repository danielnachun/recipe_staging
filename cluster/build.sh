#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

autoreconf --force --verbose --install
./configure --disable-silent \
    --disable-dependency-tracking \
    --without-x \
    --prefix=${PREFIX}
make
make install
