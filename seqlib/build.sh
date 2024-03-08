#!/usrbin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i "s?emmintrin.h?simde/x86/sse2.h?" SeqLib/ssw.h
    sed -i "s?emmintrin.h?simde/x86/sse2.h?" src/ssw.c
    export CFLAGS="${CFLAGS} -DSIMDE_ENABLE_NATIVE_ALIASES"
fi

export ACLOCAL_PATH="${PREFIX}/share/aclocal"
autoreconf --force --verbose --install
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make LIBTOOL="${SRC_DIR}/libtool"
make seqtools LIBTOOL="${SRC_DIR}/libtool"
make install

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/include
mkdir -p ${PREFIX}/lib

install -m 755 bin/seqtools ${PREFIX}/bin
cp -r lib/* ${PREFIX}/lib
cp -r SeqLib ${PREFIX}/include
