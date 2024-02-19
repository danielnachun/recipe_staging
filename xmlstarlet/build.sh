#!/usr/bin/env bash

autoreconf --force --verbose --install
./configure --prefix=${PREFIX}
make
make tests
make install
