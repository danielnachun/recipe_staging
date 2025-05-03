#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DENABLE_BUNDLED_ICONV=OFF \
    -DENABLE_BUNDLED_ICU=OFF \
    -DENABLE_BUNDLED_LIBCURL=OFF \
    -DENABLE_BUNDLED_LIBYAML=OFF \
    -DENABLE_BUNDLED_MSGPUCK=OFF \
    -DENABLE_BUNDLED_OPENSSL=OFF \
    -DENABLE_BUNDLED_READLINE=OFF \
    -DENABLE_BUNDLED_ZLIB=OFF \
    -DOPENSSL_USE_STATIC_LIBS=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
