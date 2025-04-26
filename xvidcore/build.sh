#!/usr/bin/env bash

cd build/generic
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make
make install

ln -f ${PREFIX}/lib/libxvidcore.4${SHLIB_EXT} ${PREFIX}/lib/libxvidcore${SHLIB_EXT}
