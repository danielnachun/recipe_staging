#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export ACLOCAL_PATH=${PREFIX}/share/aclocal

./autogen.sh
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make install
