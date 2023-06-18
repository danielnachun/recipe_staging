#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf lib*/*_p.mk
smake INS_BASE=${PREFIX} INS_RBASE=${PREFIX} CFLAGS="-Wno-implicit-function-declaration -Wno-implicit-int" install
 
rm -rf ${PREFIX}/include/schily \
    ${PREFIX}/lib/libschily.a \
    ${PREFIX}/lib/libdeflt.a \
    ${PREFIX}/lib/libfind.a \
    ${PREFIX}/share/man/man5
