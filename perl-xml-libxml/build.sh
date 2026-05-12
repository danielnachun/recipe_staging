#!/bin/bash
set -ex

if [ `uname -s` == "Darwin" ]; then
    CFLAGS="${CFLAGS} -Wno-incompatible-function-pointer-types"
else
    CFLAGS="${CFLAGS} -Wno-incompatible-pointer-types -Doff64_t=__off64_t"
fi

# Make sure this goes in site
perl Makefile.PL INSTALLDIRS=site CCFLAGS="${CFLAGS}" LIBS="-L${PREFIX}/lib -lxml2" INC="-I$PREFIX/include/libxml2 -I$PREFIX/include -I${CONDA_BUILD_SYSROOT}/usr/include" CC=${CC} LD=${CC}
make CC=${CC} LD=${CC} OTHERLDFLAGS="--sysroot=${CONDA_BUILD_SYSROOT}"
#make test
make install CC=${CC} LD=${CC}

cp ${PREFIX}/man/man1/perlartistic.1 ${SRC_DIR}
cp ${PREFIX}/man/man1/perlgpl.1 ${SRC_DIR}
