#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --mandir=${PREFIX}/share/man \
    --infodir=${PREFIX}/share/info \
    --program-prefix=s

make install
mv ${PREFIX}/share/info/sed.info ${PREFIX}/share/info/ssed.info
