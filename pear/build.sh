#!/bin/bash
set -xeuo pipefail
./configure --prefix=$PREFIX LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)" CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
make
make install
ln -s $PREFIX/bin/pear $PREFIX/bin/pearRM
