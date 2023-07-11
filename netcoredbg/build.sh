#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ $target_platform =~ .*linux.* ]]; then
    export CC=${BUILD_PREFIX}/bin/clang
    export CXX=${BUILD_PREFIX}/bin/clang++
fi

cmake -S . -B build ${CMAKE_ARGS} -DDOTNET_DIR=${DOTNET_ROOT}
cmake --build build
cmake --install build
