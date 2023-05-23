#!/usr/bin/env bash
#
set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?-D_FILE_OFFSET_BITS=64?-D_FILE_OFFSET_BITS=64 -I${PREFIX}/include?g" CMakeLists.txt

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF

cmake --build build
cmake --install build

install -Dd ${PREFIX}/bin
install -Dm 755 build/bin/metal ${PREFIX}/bin
