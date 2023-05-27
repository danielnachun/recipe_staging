#!/bin/bash

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    CXX=${CXX} \
    CXXFLAGS="-I${PREFIX}/include"

make
make install
