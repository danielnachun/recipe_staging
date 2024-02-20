#!/bin/bash

autoreconf --force --verbose --install
./configure \
    --prefix=$PREFIX \
    --disable-dependency-tracking \
    --mandir=$PREFIX/share/man \
    --infodir=$PREFIX/share/info \
    || (cat config.log; false)


make -j$CPU_COUNT
make check -j$CPU_COUNT
make install
