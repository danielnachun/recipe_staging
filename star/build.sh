#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

echo "Building STAR"
mkdir -p $PREFIX/bin
cd source

AMD64_SIMD_LEVELS=("avx2" "avx" "sse4.1" "ssse3" "sse3")

export CXXFLAGS="${CXXFLAGS} -Wno-register"
if [[ ${target_platform} =~ .*osx.* ]]; then
    export CXXFLAGS="${CXXFLAGS} -DCOMPILE_FOR_MAC"
fi

if [ "$(arch)" == "x86_64" ]; then
    for SIMD in ${AMD64_SIMD_LEVELS[@]}; do
        make -j${CPU_COUNT} CXXFLAGSextra="-m$SIMD" STAR STARlong CXX="${CXX} ${CXXFLAGS}"
        cp STAR $PREFIX/bin/STAR-$SIMD
        cp STARlong $PREFIX/bin/STARlong-$SIMD
        make clean
    done
    make STAR STARlong
    cp STAR $PREFIX/bin/STAR-plain
    cp STARlong $PREFIX/bin/STARlong-plain
    cp ${RECIPE_DIR}/simd-dispatch.sh $PREFIX/bin/STAR
    cp ${RECIPE_DIR}/simd-dispatch.sh $PREFIX/bin/STARlong
else
    make -j${CPU_COUNT} STAR STARlong CXX="${CXX} ${CXXFLAGS}"
    cp STAR $PREFIX/bin/STAR
    cp STARlong $PREFIX/bin/STARlong
fi

chmod +x $PREFIX/bin/STAR
chmod +x $PREFIX/bin/STARlong
