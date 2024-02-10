#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*linux.* ]]; then
    mkdir -p build
    cd build

    cmake .. ${CMAKE_ARGS} \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER=${CC} \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DZIG_STATIC_LLVM=OFF \
      -DZIG_TARGET_TRIPE=native-linux-2.17

    cmake --build .
    cmake --install . -v
else
    mkdir -p ${PREFIX}/bin
    mkdir -p ${PREFIX}/lib/zig
    install -m 755 zig ${PREFIX}/bin
    cp -R lib/* ${PREFIX}/lib/zig
fi
