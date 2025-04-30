#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DDETRAY_USE_SYSTEM_LIBS=ON \
    -DDETRAY_EIGEN_PLUGIN=ON \
    -DDETRAY_SMATRIX_PLUGIN=ON \
    -DDETRAY_SVG_DISPLAY=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}

cmake --build build -j${CPU_COUNT}
cmake --install build
