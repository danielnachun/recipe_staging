#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

CFLAGS="-fPIC -std=gnu89"

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --enable-shared \
    --mandir=${PREFIX}/share/man
make install AR=${AR}
make test AR=${AR}
