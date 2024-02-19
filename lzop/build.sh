#!/bin/bash

autoreconf --force --verbose --install
./configure --prefix=${PREFIX}
make -j ${CPU_COUNT}
make install
