#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -fcommon"
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make install
