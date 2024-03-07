#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/PRIVATE  ${mkl_include_dir} PRIVATE ${rmath_lib_dir}/PRIVATE  ${mkl_include_dir} PRIVATE ${rmath_include_dir}/g' CMakeLists.txt

if [[ ${target_platform} == "osx-64" ]]; then
    sed -i 's/gnu_thread/intel_thread/g' CMakeLists.txt
fi

if [[ ${target_platform} != "osx-arm64" ]]; then
    blas_arg="-Dmkl_path=${PREFIX}"
else
    blas_arg="-Dblas_path=${PREFIX}"
fi

cmake -S . -B build \
    -Dzlib_path=${PREFIX} \
    -Dgsl_path=${PREFIX} \
    -Deigen_path=${PREFIX}/include \
    ${blas_arg} \
    -Drmath_lib_path=${PREFIX}/lib \
    -Drmath_include_path=${PREFIX}/lib/R/include \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF

cmake --build build

mkdir -p ${PREFIX}/bin
install -m 755 build/osca ${PREFIX}/bin
