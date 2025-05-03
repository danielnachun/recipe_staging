#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CPPFLAGS="${CPPFLAGS} -Wno-register"

./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make install

mkdir -p ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/darts/darts ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/darts/mkdarts ${PREFIX}/bin
