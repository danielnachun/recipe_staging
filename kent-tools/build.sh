#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd src
sed -i 's/DESTDIR=${HOME}\/bin//g' parasol/makefile
sed -i 's/ld/${LD}/g' hg/lib/straw/makefile
sed -i "s|-I../../../inc|-I../../../inc -I${PREFIX}/include|g" hg/lib/straw/makefile
sed -i 's?\${PREFIX}/lib/libssl.a \${PREFIX}/lib/libcrypto.a?-lcrypto -lssl?g' inc/common.mk
sed -i "s/= ar/= ${AR}/" submodules/htslib/Makefile
sed -i "s/= ranlib/= ${RANLIB}/" submodules/htslib/Makefile
sed -i "s/= gcc/= ${CC}/" submodules/htslib/Makefile
sed -i "s?-fvisibility=hidden?-fvisibility=hidden ${LDFLAGS} ${CFLAGS}?" submodules/htslib/Makefile

sed -i 's/${CONDA_BUILD},1/${CONDA_BUILD},0/' inc/common.mk

# Set LD_LIBRARY_PATH because setting RPATH wtih LDFLAGS causes segfault
export LD_LIBRARY_PATH="${PREFIX}/lib"

make userApps BINDIR=${PREFIX}/bin \
    ICONVLIB="-liconv" \
    SCRIPTS="${PREFIX}/bin" \
    PNGLIB="-L${PREFIX}/lib -lpng -lz" \
    PNGINCL="-I${PREFIX}/include" \
    MYSQLLIBS="${LDFLAGS} -lmysqlclient -lz -lstdc++" \
    MYSQLINCL="-I${PREFIX}/include/mysql"

mv ${PREFIX}/bin/calc ${PREFIX}/bin/kent-tools-calc
