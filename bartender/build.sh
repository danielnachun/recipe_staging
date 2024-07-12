#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
make all CC=${CXX} CFLAGS="${CXXFLAGS} -O3 -std=c++11 -pthread" SINGLELDFLAGS="${LDFLAGS} -pthread" COMBINERLDFLAGS="${LDFLAGS} -pthread"
make install INSTALLDIR=${PREFIX}/bin
