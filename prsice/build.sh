#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -DDYNAMIC_ZLIB"
cmake -S . -B build -DEIGEN_INCLUDE_DIR=${PREFIX}/include/eigen3 -DCMAKE_VERBOSE_MAKEFILE=ON ${CMAKE_ARGS}
cmake --build build -- -j ${CPU_COUNT}
cmake --install build

mkdir -p ${PREFIX}/bin
install -m 755 ${SRC_DIR}/bin/PRSice ${PREFIX}/bin/PRSice
