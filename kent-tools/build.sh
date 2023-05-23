#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd src
sed -i 's/DESTDIR=${HOME}\/bin//g' parasol/makefile
sed -i 's/ld/${LD}/g' hg/lib/straw/makefile
sed -i "s|-I../../../inc|-I../../../inc -I${PREFIX}/include|g" hg/lib/straw/makefile
sed -i 's?\${PREFIX}/lib/libssl.a \${PREFIX}/lib/libcrypto.a?-lcrypto -lssl?g' inc/common.mk

make userApps BINDIR=${PREFIX}/bin \
    SCRIPTS="${PREFIX}/bin" \
    PNGLIB="-L${PREFIX}/lib -lpng -lz" \
    PNGINCL="-I${PREFIX}/include" \
    MYSQLLIBS="-L${PREFIX}/lib -lmysqlclient -lz -lstdc++" \
    MYSQLINCL="-I${PREFIX}/include/mysql"

mv ${PREFIX}/bin/calc ${PREFIX}/bin/kent-tools-calc
