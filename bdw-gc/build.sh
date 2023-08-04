#!/usr/bin/env bash

CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++17/-std=c++14/g")

./autogen.sh
./configure --disable-debug --disable-dependency-tracking --prefix=${PREFIX} --enable-cplusplus

make
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi
make install
