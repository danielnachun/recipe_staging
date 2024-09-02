#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s|LEAN_EXTRA_CXX_FLAGS \"\"|LEAN_EXTRA_CXX_FLAGS \"-I${PREFIX}/include\"|" stage0/src/CMakeLists.txt
sed -i "s|LEAN_EXTRA_CXX_FLAGS \"\"|LEAN_EXTRA_CXX_FLAGS \"-I${PREFIX}/include\"|" src/CMakeLists.txt
cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --build build -j${CPU_COUNT} --target stage2
cmake --build build -j${CPU_COUNT} --target stage3
make -C build/stage3 install
