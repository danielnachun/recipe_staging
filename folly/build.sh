#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -DGLOG_USE_GLOG_EXPORT"

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTS=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DPYTHON_EXTENSIONS=OFF \
    -DCMAKE_CXX_STANDARD=20 \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
