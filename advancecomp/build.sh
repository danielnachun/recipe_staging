#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

autoreconf --force --verbose --install
./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --mandir=${PREFIX}/share/man \
    --enable-bzip2
make install
