#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p third_party/robin-map/include
ln -sf ${BUILD_PREFIX}/include/tsl ${SRC_DIR}/third_party/robin-map/include

cmake -S . -B build \
    -DCMAKE_C_COMPILER=${BUILD_PREFIX}/bin/clang \
    -DCMAKE_CXX_COMPILER=${BUILD_PREFIX}/bin/clang++ \
    -DENABLE_OBJCXX=OFF \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF

cmake --build build
cmake --install build
