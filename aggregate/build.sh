#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's?$(prefix)/man/man1?$(prefix)/share/man/man1?g' Makefile.in
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1
export CFLAGS="-Wno-implicit-int"

./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
