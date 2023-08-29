#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd src
make CXX="${CXX} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -I${PREFIX}/include" 

mkdir -p ${PREFIX}/bin
install -m 755 mtPGS ${PREFIX}/bin
