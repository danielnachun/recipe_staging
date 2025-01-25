#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PYTHON=${BUILD_PREFIX}/bin/python
export ACLOCAL_PATH=${PREFIX}/share/aclocal

./bootstrap
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --without-included-gettext \
    --prefix=${PREFIX}
make install
