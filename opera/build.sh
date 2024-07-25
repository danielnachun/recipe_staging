#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*osx.* ]]; then
    omp="-lomp"
else
    omp="-lgomp"
fi
export EIGEN3_INCLUDE_DIR=${PREFIX}/include/eigen3
make LIB="${LDFLAGS} -lz ${omp}" CXX="${CXX}" BOOST="${PREFIX}/include" OUTPUT=opera
mkdir -p ${PREFIX}/bin
install -m 755 opera ${PREFIX}/bin
