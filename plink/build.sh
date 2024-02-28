#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export BLASFLAGS="-L${PREFIX}/lib"
if [[ ${target_platform} == "osx-arm64" ]]; then
    export BLASFLAGS="${BLASFLAGS} -lopenblas"
else
    # Don't strip dylibs on macOS Intel
    if [[ ${target_platform} == "osx-64" ]]; then
        export LDFLAGS="$(echo "${LDFLAGS}" | sed -e 's/-Wl,-dead_strip_dylibs//')"
    fi
    export BLASFLAGS="${BLASFLAGS} -lmkl_core -lmkl_intel_thread -lmkl_intel_lp64 -liomp5"
fi
make CXX="${CXX} -DDYNAMIC_ZLIB -Wno-c++11-narrowing" CC="${CC} -DDYNAMIC_ZLIB" BLASFLAGS="${BLASFLAGS}" MACFLAGS="" ZLIB=${PREFIX}/lib/libz${SHLIB_EXT}

mkdir -p ${PREFIX}/bin
install -m 755 plink ${PREFIX}/bin
