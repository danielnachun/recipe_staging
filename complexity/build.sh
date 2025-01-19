#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-int"
cd src
    autogen opts.def
cd ..
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make
make install
