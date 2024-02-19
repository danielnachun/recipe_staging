#!/bin/sh

export CXXFLAGS="${CXXFLAGS} -Wno-register"
autoreconf --force --verbose --install
./configure --prefix=${PREFIX}
make
make install
