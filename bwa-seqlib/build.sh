#!/usrbin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -fcommon"
if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i 's?emmintrin.h?simde/x86/sse2.h?' ksw.c
    export CFLAGS="${CFLAGS} -DSIMDE_ENABLE_NATIVE_ALIASES"
fi

make all CC="${CC} ${CFLAGS} ${LDFLAGS}"
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include/bwa

install -m 755 bwa ${PREFIX}/bin
install -m 644 libbwa.dylib ${PREFIX}/lib
cp -R *.h ${PREFIX}/include/bwa
cp -R *.c ${PREFIX}/include/bwa
