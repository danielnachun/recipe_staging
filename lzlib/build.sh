#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s/-Wl,--soname=/-install_name /g" Makefile.in

./configure --disable-debug \
    --disable-dependency-tracking \
    --enable-shared \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    CC=${CC}

make
make install
