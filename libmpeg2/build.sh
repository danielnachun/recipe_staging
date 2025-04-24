#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -std=gnu89"
export ACLOCAL_PATH=${PREFIX}/share/aclocal

autoreconf --force --install --verbose
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
