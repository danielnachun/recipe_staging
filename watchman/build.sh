#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -DGLOG_USE_GLOG_EXPORT"
export RUSTUP_TOOLCHAIN=stable

cmake -S . -B build \
    -DPython3_EXECUTABLE=${PYTHON} \
    -DENABLE_EDEN_SUPPORT=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DWATCHMAN_STATE_DIR= \
    -DWATCHMAN_VERSION_OVERRIDE=${PKG_VERSION} \
    -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
