#!/bin/bash
set -eu -o pipefail
set -x

mamba install -c conda-forge -y ldc -p ${BUILD_PREFIX}
DCMP=${BUILD_PREFIX}/bin/ldmd2

# Build latest version
cmake -S . -B build -G Ninja \
      ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DBUILD_SHARED_LIBS=BOTH \
      -DD_COMPILER=$DCMP \
      -DBUILD_LTO_LIBS=ON \
      ..
cmake --build build
cmake --install build

rm -rf build
# If we don't do this a second time, we can end up linking to the wrong version of libphobos et al.
cmake -S . -B build -G Ninja \
      ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DBUILD_SHARED_LIBS=BOTH \
      -DD_COMPILER=${PREFIX}/bin/ldmd2 \
      -DBUILD_LTO_LIBS=ON \
      ..
cmake --build build
cmake --install build
