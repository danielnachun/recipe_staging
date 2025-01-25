#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DENABLE_WAYLAND=OFF \
    -DENABLE_X11=OFF \
    -DENABLE_XCB_ERRORS=OFF \
    -DENABLE_OPENGL=OFF \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
