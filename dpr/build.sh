#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Remake bin directory
mkdir -p bin
make CPP="${CXX} -I${PREFIX}/include -I${PREFIX}/include/eigen3 -L${PREFIX}/lib -Wno-narrowing" FORCE_DYNAMIC=1

mkdir -p ${PREFIX}/bin
install -m 755 bin/DPR ${PREFIX}/bin
