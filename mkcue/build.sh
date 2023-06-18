#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

CXXFLAGS="${CXXFLAGS} -std=c++11"

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
mkdir -p ${PREFIX}/bin
make install
