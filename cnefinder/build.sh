#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*linux.* ]]; then
    cxx_stdlib="stdc++"
else
    cxx_stdlib="c++"
fi

make CC=${CC} \
    CFLAGS="-fopenmp -D_USE_OMP -O3 -fomit-frame-pointer -funroll-loops ${CXXFLAGS} " \
    LFLAGS="-std=c++11 -I ./ ${LDFLAGS} -l${cxx_stdlib}"

mkdir -p ${PREFIX}/bin
install -m 755 cnef ${PREFIX}/bin/cnef
