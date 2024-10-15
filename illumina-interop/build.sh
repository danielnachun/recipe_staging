#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/lib64/lib/g' src/interop/CMakeLists.txt
sed -i 's/lib64/lib/g' src/ext/python/CMakeLists.txt

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DENABLE_STATIC=OFF \
    -DCMAKE_OSX_ARCHITECTURES=${HOST//-*/} \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build

mkdir -p ${PREFIX}/lib/python3.12/site-packages
mv ${PREFIX}/lib/python ${PREFIX}/lib/python3.12/site-packages/interop
install -m 644 ${PREFIX}/share/illumina/interop/src/python/interop/__init__.py ${PREFIX}/lib/python3.12/site-packages/interop/__init__.py
install -m 644 ${PREFIX}/share/illumina/interop/src/python/interop/__main__.py ${PREFIX}/lib/python3.12/site-packages/interop/__main__.py
install -m 644 ${SRC_DIR}/src/ext/python/core.py ${PREFIX}/lib/python3.12/site-packages/interop/core.py
