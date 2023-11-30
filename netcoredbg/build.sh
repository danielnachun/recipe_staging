#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ $target_platform =~ .*linux.* ]]; then
    export CC=${BUILD_PREFIX}/bin/clang
    export CXX=${BUILD_PREFIX}/bin/clang++
fi

cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX}/libexec/${PKG_NAME} -DDOTNET_DIR=${DOTNET_ROOT}
cmake --build build
cmake --install build

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME} "\$@"
EOF
