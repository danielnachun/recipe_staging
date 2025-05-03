#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/0x04000000/0x3100000/' mdbx.c

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -Wno-dev \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
