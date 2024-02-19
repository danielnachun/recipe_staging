#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="-Wno-implicit-function-declaration"
autoupdate
autoreconf --force --install --verbose
./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --mandir=${PREFIX}/share/man \
    --infodir=${PREFIX}/share/info \
    --program-prefix=s

make
make install
mv ${PREFIX}/share/info/sed.info ${PREFIX}/share/info/ssed.info
