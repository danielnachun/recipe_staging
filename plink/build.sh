#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ ".*linux.*" ]]; then
    export BLASFLAGS="${BLASFLAGS} -lmkl_core -lmkl_intel_thread -lmkl_intel_lp64 -liomp5"
    make CXX="${CXX} -DDYNAMIC_ZLIB -DUSE_MKL -Wno-c++11-narrowing" CC="${CC} -DUSE_MKL -DDYNAMIC_ZLIB" BLASFLAGS="${BLASFLAGS}" ZLIB=${PREFIX}/lib/libz${SHLIB_EXT}
else
    make CXX="${CXX} -DDYNAMIC_ZLIB -Wno-c++11-narrowing" CC="${CC} -DDYNAMIC_ZLIB" ZLIB=${PREFIX}/lib/libz${SHLIB_EXT}
fi

mkdir -p ${PREFIX}/bin
install -m 755 plink ${PREFIX}/bin
