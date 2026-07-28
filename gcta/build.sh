#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export EIGEN3_INCLUDE_DIR="${PREFIX}/include/eigen3"
export SPECTRA_LIB="${PREFIX}"
export BOOST_LIB="${PREFIX}"
export LDFLAGS="${LDFLAGS} -lgsl"
export LDFLAGS=$(echo $LDFLAGS | sed 's/-Wl,-dead_strip_dylibs//g')

sed -i 's/SET(CMAKE_CXX_STANDARD 11)/SET(CMAKE_CXX_STANDARD 14)/' CMakeLists.txt
sed -i 's#INCLUDE_DIRECTORIES("submods/plink-ng/2.0")#&\nINCLUDE_DIRECTORIES("submods/plink-ng/2.0/include")#' CMakeLists.txt
sed -i 's/CMAKE_EXE_LINKER_FLAGS "/CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /g' CMakeLists.txt
sed -i 's/zstd_s/zstd/' CMakeLists.txt
sed -i '/link_directories(\/usr\/local\/lib)/d' CMakeLists.txt
# Replace the bundled (too-old) plink-ng with the newer plink2 on all platforms
rm -rf submods/plink-ng/2.0
mv plink2 submods/plink-ng/2.0

# BLAS selection is by architecture: x86_64 uses MKL (GCTA_CPU_x86 -> mkl.h),
# ARM uses OpenBLAS + the conda simde headers (GCTA_CPU_x86 undefined -> cblas.h/lapack.h)
if [[ ${target_platform} == *-64 ]]; then
    export MKLROOT="${PREFIX}"
else
    export OPENBLAS="${PREFIX}"
    export CXXFLAGS="${CXXFLAGS} -DIGNORE_BUNDLED_SIMDE"
    export CFLAGS="${CFLAGS} -DIGNORE_BUNDLED_SIMDE"
fi

# On osx-arm64 uname reports "arm64"; on linux-aarch64 CMake correctly detects "aarch64"
if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i 's/"aarch64"/"arm64"/' CMakelists.txt
fi

cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build
cmake --install build

mkdir -p ${PREFIX}/bin
install -m 755 build/gcta64 ${PREFIX}/bin/gcta
