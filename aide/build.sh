#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="-DHAVE_STRNSTR"
./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --disable-lfs \
    --disable-static \
    --with-curl \
    --with-zlib \
    --prefix=${PREFIX} \
    --sysconfdir=${PREFXI}/etc
make install
