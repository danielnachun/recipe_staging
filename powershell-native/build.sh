#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s/add_subdirectory(test)//" src/libpsl-native/CMakeLists.txt
cmake -S src/libpsl-native -B build ${CMAKE_ARGS}
cmake --build build
mkdir -p ${PREFIX}/lib
cp src/powershell-unix/libpsl-native.dylib ${PREFIX}/lib
