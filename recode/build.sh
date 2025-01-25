#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PYTHON=${BUILD_PREFIX}/bin/python
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --without-included-gettext \
    --prefix=${PREFIX}
make install
