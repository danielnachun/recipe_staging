#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's?$(HTS_ROOT)/libhts.a?-lhts?' src/Makefile

export CFLAGS="${CFLAGS} -fcommon"
mkdir ${SRC_DIR}/obj
mkdir ${SRC_DIR}/bin
make -C src \
    CC=${CC} \
    HTS_ROOT=${PREFIX}/include/htslib \
    INCLUDES=-I${PREFIX}/lib \
    LIBS="${LDFLAGS} -lz -lcurl -ldl -lm -pthread"
mkdir -p ${PREFIX}/bin
install -m 755 ${SRC_DIR}/bin/* ${PREFIX}/bin
install -m 644 ${SRC_DIR}/lib/libgiggle.a ${PREFIX}/lib
