#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DSIO_EXAMPLES=OFF \
    -DSIO_BUILTIN_ZLIB=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
