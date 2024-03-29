#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?gsl/include?$PREFIX/include?g" Makefile
sed -i "s?gsl/lib?$PREFIX/lib?g" Makefile
sed -i "s?MKL/lib?$PREFIX/lib?g" Makefile

if [[ ${target_platform} =~ .*osx.* ]]; then
    sed -i "s/--no-as-needed,//" Makefile
fi

sed -i 's?x86intrin.h?simde/x86/avx512.h?' mcmc.cpp
sed -i 's?xmmintrin.h?simde/x86/sse.h?' sse_mathfun.h
sed -i 's?emmintrin.h?simde/x86/sse2.h?' sse_mathfun.h

if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i 's/-lmkl_rt/-lopenblas/' Makefile
fi

make CC="${CXX} -DSIMDE_ENABLE_NATIVE_ALIASES"

mkdir -p ${PREFIX}/inb
install -m 755 SDPR ${PREFIX}/bin
