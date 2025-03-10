#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure.py \
    --prefix=${PREFIX} \
    --with-bzip \
    --with-lzma \
    --with-zlib \
    --with-boost \
    --with-sqlite3
make -j${CPU_COUNT}
make install
