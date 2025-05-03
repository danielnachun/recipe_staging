#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/msgpuck STATIC/msgpuck SHARED/g' CMakeLists.txt

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
