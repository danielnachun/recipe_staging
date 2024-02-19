#!/bin/sh

autoreconf --force --verbose --install
./configure --prefix=${PREFIX}
make
make install
