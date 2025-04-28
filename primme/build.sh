#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/include
mkdir -p ${PREFIX}/lib
make solib
make install includedir=${PREFIX}/include libdir=${PREFIX}/lib
