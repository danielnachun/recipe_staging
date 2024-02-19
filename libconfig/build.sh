#!/bin/sh

autoreconf -i
./configure --prefix=$PREFIX
make
make check
make install
