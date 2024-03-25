#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's|-I/usr/local/include||' build_dynamic/Makefile
sed -i 's|-L/usr/local/lib||' build_dynamic/Makefile

export EXTRA_FLAGS=""
if [[ ${target_platform} =~ .*linux.* ]]; then
    export EXTRA_FLAGS="${EXTRA_FLAGS} DYNAMIC_MKL=1"
fi
if [[ ${target_platform} == "osx-64" ]]; then
    export EXTRA_FLAGS="${EXTRA_FLAGS} NO_SSE42=1"
fi
cd build_dynamic
make CXX="${CXX}" CC=${CC} CXXFLAGS="${CXXFLAGS} -I. -std=c++11" CFLAGS="${CFLAGS} -I. -O2 -std=gnu99" LINKFLAGS="${LDFLAGS} -lm -pthread -lzstd -lz" STATIC_ZSTD=""
mkdir -p ${PREFIX}/bin
install -m 755 plink2 ${PREFIX}/bin
