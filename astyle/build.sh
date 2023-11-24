#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd src
make CXX=${CXX} -f ../build/gcc/Makefile

mkdir -p ${PREFIX}/bin
install -m 755 bin/astyle ${PREFIX}/bin
