#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s/inline int/int/g" database.c

autoreconf --force --install --verbose
./configure --disable-debug \
    --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --mandir=${PREFIX}/share/man
make install
