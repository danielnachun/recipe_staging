#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -DGLOG_USE_GLOG_EXPORT"
export LDFLAGS="${LDFLAGS} -Wl,-dead_strip_dylibs"

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    -DPYTHON_EXTENSIONS=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
