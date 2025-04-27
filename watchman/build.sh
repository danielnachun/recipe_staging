#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -DGLOG_USE_GLOG_EXPORT -D_LIBCPP_HAS_NO_ASAN"
export RUSTUP_TOOLCHAIN=stable

cmake -S . -B build \
    -DPython3_EXECUTABLE=${PYTHON} \
    -DUSE_SYS_PYTHON=ON \
    -DENABLE_EDEN_SUPPORT=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DWATCHMAN_STATE_DIR= \
    -DWATCHMAN_VERSION_OVERRIDE=${PKG_VERSION} \
    -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cp build/watchman/cli/**/release/watchmanctl build/watchman/cli/release
install -m 644 build/libeden_config_thrift.dylib ${PREFIX}/lib
install -m 644 build/libeden_service_thrift.dylib ${PREFIX}/lib
install -m 644 build/libstreamingeden_thrift.dylib ${PREFIX}/lib
cmake --install build
