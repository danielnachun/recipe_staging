#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Allow older kernel headers on Linux
sed -i 's/0x04000000/0x3100000/' mdbx.c

case ${target_platform} in
    osx-64)
        export CMAKE_ARGS="-DCMAKE_OSX_ARCHITECTURES=x86_64 ${CMAKE_ARGS}" ;;
    osx-arm64)
        export CMAKE_ARGS="-DCMAKE_OSX_ARCHITECTURES=arm64 ${CMAKE_ARGS}" ;;
esac

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
