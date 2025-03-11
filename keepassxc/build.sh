#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build \
    -DKEEPASSXC_BUILD_TYPE=Release \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    -DWITH_GUI_TESTS=ON \
    -DWITH_XC_UPDATECHECK=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}

mkdir -p ${PREFIX}/bin
install -m 755 build/src/cli/keepassxc-cli ${PREFIX}/bin
