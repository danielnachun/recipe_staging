#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
export CFLAGS="${CFLAGS} -Wno-incompatible-function-pointer-types"
export CFLAGS="${CFLAGS} -fcommon"

autoreconf --force --install --verbose
./configure --disable-silent \
    --disable-dependency-tracking \
    --disable-gtk \
    --prefix=${PREFIX} \
    --with-readline=${PREFIX}/lib \
    --without-tcl \
    --without-tk \
    --without-x
make
make install
