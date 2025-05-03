#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration -Wno-int-conversion"

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DENABLE_BUNDLED_ICONV=OFF \
    -DENABLE_BUNDLED_ICU=OFF \
    -DENABLE_BUNDLED_LIBCURL=OFF \
    -DENABLE_BUNDLED_LIBYAML=OFF \
    -DENABLE_BUNDLED_OPENSSL=OFF \
    -DENABLE_BUNDLED_READLINE=OFF \
    -DENABLE_BUNDLED_ZLIB=OFF \
    -DOPENSSL_USE_STATIC_LIBS=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
