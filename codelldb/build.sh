#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

if [[ ${target_platform} ]]; then
    exprt LLVM_TRIPLE="arm64-apple-darwin"
fi

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    -DLLDB_PACKAGE=${BUILD_PREFIX} \
    ${CMAKE_ARGS}

cmake --build build

mkdir -p ${PREFIX}/bin
install -m 755 ./build/target/**/release/codelldb ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
install -m 644 ./build/adapter/libcodelldb${SHLIB_EXT} ${PREFIX}/lib
