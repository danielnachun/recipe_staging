#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/OPENSSL_USE_STATIC_LIBS TRUE/OPENSSL_USE_STATIC_LIBS FALSE/' cmake/OpenSSL.cmake
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DOPENSSL_ROOT_DIR=${PREFIX} \
    -DOPENSSL_USE_STATIC_LIBS=OFF \
    -DDORADO_LIBTORCH_DIR=${PREFIX} \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
