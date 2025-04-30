#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i '/set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")/d' CMakeLists.txt

cmake -S . -B build \
    -DPython3_EXECUTABLE=${PYTHON} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DENABLE_SIO=ON \
    -DPODIO_RELAX_PYVER=ON \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
