#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -DGLOG_USE_GLOG_EXPORT"

if [[ ${target_platform} =~ .*osx.* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,-undefined,dynamic_lookup -Wl,-dead_strip_dylibs"
fi

sed -i '/#include <linux\/ipv6.h>/d' quic/xsk/XskSender.h

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
