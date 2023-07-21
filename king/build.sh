#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

${CXX} -I${CXX_INCLUDE_PATH} -L${LIBRARY_PATH} -lm -lz -O2 -fopenmp -o king *.cpp
mkdir -p $PREFIX/bin
install -m 755 ./king $PREFIX/bin/king
