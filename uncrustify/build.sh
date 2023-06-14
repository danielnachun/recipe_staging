#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build -G Ninja\
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF

cmake --build build
cmake --install build

mkdir -p ${PREFIX}/share/doc/${PKG_NAME}
cp -r documentation/* ${PREFIX}/share/doc/${PKG_NAME}

