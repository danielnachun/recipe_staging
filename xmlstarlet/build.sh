#!/usr/bin/env bash

export CFLAGS="${CFLAGS} -Wno-incompatible-function-pointer-types"
autoreconf --force --verbose --install
./configure --prefix=${PREFIX}
make
make tests
make install
