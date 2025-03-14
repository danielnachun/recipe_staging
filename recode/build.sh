#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PYTHON=${BUILD_PREFIX}/bin/python
export ACLOCAL_PATH=${PREFIX}/share/aclocal
export LEX=${BUILD_PREFIX}/bin/flex

./bootstrap
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --without-included-gettext \
    --prefix=${PREFIX}

sed -i '/dist_man_MANS = recode.1/d' src/Makefile
make install
