#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -DGLOG_USE_GLOG_EXPORT"

cmake -S wangle -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    -DBUILD_SHARED_LIBS=ON \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build

sed -i "s?${CONDA_BUILD_SYSROOT}/usr/lib/librt.so?rt?" ${PREFIX}/lib/cmake/wangle/wangle-targets.cmake
