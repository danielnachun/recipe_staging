#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

CFLAGS="-Wno-implicit-int -Wno-implicit-function-declaration"

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --mandir=${PREFIX}/share/man \
    --infodir=${PREFIX}/share/info \
    --enable-shared=yes \
    --enable-static=no \
    --without-x
make install
