#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export EIGEN3_INCLUDE_DIR="${PREFIX}/include/eigen3"
export SPECTRA_LIB="${PREFIX}"
export BOOST_LIB="${PREFIX}"
export LDFLAGS="${LDFLAGS} -lgsl"
export LDFLAGS=$(echo $LDFLAGS | sed 's/-Wl,-dead_strip_dylibs//g')

sed -i 's/CMAKE_EXE_LINKER_FLAGS "/CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /g' CMakeLists.txt
sed -i 's/zstd_s/zstd/' CMakeLists.txt
sed -i '/link_directories(\/usr\/local\/lib)/d' CMakeLists.txt
if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i 's/"aarch64"/"arm64"/' CMakelists.txt
    export OPENBLAS="${PREFIX}"
    rm -rf submods/plink-ng
    mv plink2 submods/plink-ng
    sed -i 's|pgenlib_misc.h|include/pgenlib_misc.h' submods/Pgenlib/PgenReader.cpp
    sed -i 's|plink2_baseh.h|include/plink2_base.h' submods/Pgenlib/PgenReader.cpp
    sed -i 's|pgenlib_read.h|include/pgenlib_read.h' submods/Pgenlib/PgenReader.h
else
    export MKLROOT="${PREFIX}"
fi

cmake -S . -B build ${CMAKE_ARGS}
cmake --build build
cmake --install build

mkdir -p ${PREFIX}/bin
install -m 755 build/gcta64 ${PREFIX}/bin/gcta
