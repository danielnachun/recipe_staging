#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i 's?emmintrin.h?simde/x86/sse2.h?' ksw.c
    export CFLAGS="${CFLAGS} -DSIMDE_ENABLE_NATIVE_ALIASES"
fi

make CFLAGS="${CFLAGS} -fcommon"
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/man/man1
cp bwa $PREFIX/bin
cp xa2multi.pl $PREFIX/bin
cp qualfa2fq.pl $PREFIX/bin
cp bwa.1 $PREFIX/share/man/man1
