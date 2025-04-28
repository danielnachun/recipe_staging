#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DHNSWLIB_EXAMPLES=OFF \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}

cmake --build build -j${CPU_COUNT}
cmake --install build
