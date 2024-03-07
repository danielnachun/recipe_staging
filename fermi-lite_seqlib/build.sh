#!/usrbin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -fcommon"
if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i 's?emmintrin.h?simde/x86/sse2.h?' f_ksw.c
    export CFLAGS="${CFLAGS} -DSIMDE_ENABLE_NATIVE_ALIASES"
fi

make all CC="${CC} ${CFLAGS} ${LDFLAGS}"
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include/fermi-lite

install -m 755 fml-asm ${PREFIX}/bin
install -m 644 libfml${SHLIB_EXT} ${PREFIX}/lib
cp -R *.h ${PREFIX}/include/fermi-lite
cp -R *.c ${PREFIX}/include/fermi-lite
