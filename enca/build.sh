#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export export ACLOCAL_PATH=${PREFIX}/share/aclocal

autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --with-librecode=${PREFIX} \
    --enable-external
make install
