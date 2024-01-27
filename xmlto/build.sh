#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export XML_CATALOG_FILES=${PREFIX}/etc/catalog
export CFLAGS="${CFLAGS} -Wno-implicit-int"
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib
make install
