#!/usr/bin/env bash

cd build/generic
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make
make install

if [[ ${target_platform} =~ .*osx.* ]]; then
    ln -f ${PREFIX}/lib/libxvidcore.4${SHLIB_EXT} ${PREFIX}/lib/libxvidcore${SHLIB_EXT}
else
    ln -f ${PREFIX}/lib/libxvidcore${SHLIB_EXT}.4 ${PREFIX}/lib/libxvidcore${SHLIB_EXT}
fi
