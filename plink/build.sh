#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export EXTRA_CFLAGS="-DDYNAMIC_ZLIB"
export ZLIB="${PREFIX}/lib/libz${SHLIB_EXT}"
sed -i 's/Rconnection.o//' Makefile

if [[ ${target_platform} =~ .*linux.* ]]; then
    export BLASFLAGS="-L${PREFIX}/lib -lmkl_core -lmkl_intel_thread -lmkl_intel_lp64 -liomp5"
    make CXX="${CC} ${EXTRA_CFLAGS} -DUSE_MKL" CC="${CC} ${EXTRA_CFLAGS} -DUSE_MKL" BLASFLAGS="${BLASFLAGS}" ZLIB="${ZLIB}"
else
    if [[ ${target_platform} == "osx-arm64" ]]; then
        export EXTRA_CFLAGS="${EXTRA_CFLAGS} -I${PREFIX}/include/simde"
        #export EXTRA_CXXFLAGS="${EXTRA_CXXFLAGS} -I${PREFIX}/include/simde"
    fi
    make CXX="${CC} ${EXTRA_CFLAGS}" CC="${CC} ${EXTRA_CFLAGS}" ZLIB="${ZLIB}"
fi

mkdir -p ${PREFIX}/bin
install -m 755 plink ${PREFIX}/bin
