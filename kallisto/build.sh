#!/bin/bash

cd ext/htslib || exit 1
autoreconf --force --install --verbose
./configure
cd ../.. || exit 1
mkdir -p "${PREFIX}/bin"
sed -i 's/ENABLE_AVX2 MATCHES "OFF"/CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64" AND ENABLE_AVX2 MATCHES "OFF"/' ext/bifrost/CMakeLists.txt
mkdir -p build
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" .. -DUSE_HDF5=ON
make
make install
