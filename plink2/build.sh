#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's|-I/usr/local/include||' 2.0/build_dynamic/Makefile
sed -i 's|-L/usr/local/lib||' 2.0/build_dynamic/Makefile
# The no-static-zstd branch of the Makefile redefines OBJ but drops
# $(GCSRC:.c=.o), so mini-gmp.o is compiled but never linked. Add it back.
sed -i 's|OBJ = $(CSRC:.c=.o) $(CCSRC:.cc=.o)|OBJ = $(CSRC:.c=.o) $(GCSRC:.c=.o) $(CCSRC:.cc=.o)|' 2.0/build_dynamic/Makefile

export LDFLAGS=$(echo ${LDFLAGS} | sed 's/-Wl,-dead_strip_dylibs//g')
export EXTRA_FLAGS=""
if [[ ${target_platform} == "linux-64" ]]; then
    export EXTRA_FLAGS="${EXTRA_FLAGS} DYNAMIC_MKL=1"
    export CFLAGS="${CFLAGS} -DUSE_MKL -DLAPACK_ILP64"
    export CXXFLAGS="${CXXFLAGS} -DUSE_MKL -DLAPACK_ILP64"
fi
if [[ ${target_platform} != "linux-64" ]]; then
    export CFLAGS="${CFLAGS} -DIGNORE_BUNDLED_SIMDE"
    export CXXFLAGS="${CXXFLAGS} -DIGNORE_BUNDLED_SIMDE"
fi
cd 2.0/build_dynamic
make CXX="${CXX}" CC=${CC} CXXFLAGS="${CXXFLAGS} -std=c++11" CFLAGS="${CFLAGS} -I. -O2 -std=gnu99" LINKFLAGS="${LDFLAGS} -lm -pthread -lzstd -lz" STATIC_ZSTD="" ${EXTRA_FLAGS}
mkdir -p ${PREFIX}/bin
install -m 755 plink2 ${PREFIX}/bin
