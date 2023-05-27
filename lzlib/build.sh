#!/bin/bash

./configure --disable-debug \
    --disable-dependency-tracking \
    --enable-shared \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    CC=${CC} \
    AR=${AR}

make
make install
