#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build \
    -Dzlib_path=${PREFIX}/include \
    -Deigen_path=${PREFIX}/include/eigen3 \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF

cmake --build build

mkdir -p ${PREFIX}/bin
install -m 755 build/smr ${PREFIX}/bin
