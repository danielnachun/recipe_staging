#!/usr/bin/env bash

BLASFLAGS="-L${PREFIX}/lib"
if [[ ${target_platform} == "osx-arm64"]]; then
    BLASFLAGS="${BLASFLAGS} -lopenblas"
else
    BLASFLAGS="${BLASFLAGS} -lmkl_core -lmkl_intel_thread -lmkl_intel_lp64 -liomp5"
fi
make CXX=${CXX} CC=${CC} MACFLAGS="" ZLIB=${PREFIX}/lib/libz${SHLIB_EXT}
