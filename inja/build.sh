#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    -DCOVERALLS=OFF \
    -DINJA_EXPORT=ON \
    -DINJA_INSTALL=ON \
    -DINJA_BUILD_TESTS=OFF \
    -DBUILD_BENCHMARK=OFF \
    -DINJA_USE_EMBEDDED_JSON=OFF \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}

cmake --build build -j${CPU_COUNT}
cmake --install build
