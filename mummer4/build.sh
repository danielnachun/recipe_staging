#!/bin/bash

set -xe

autoreconf --force --verbose --install
./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make install
