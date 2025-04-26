#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export ACLOCAL_PATH=${PREFIX}/share/aclocal

sed -i 's/dist-lzma/dist-xz/' configure.ac

autoreconf --force --install --verbose
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make install
