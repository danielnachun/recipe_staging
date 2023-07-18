#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

arc unarchive DPR.rar
cd DPR
make clean
make CPP="${CXX} -I${PREFIX}/include -L${PREFIX}/lib -Wno-narrowing -Wl,--allow-multiple-definition" FORCE_DYNAMIC=1

mkdir -p ${PREFIX}/bin
install -m 755 bin/DPR ${PREFIX}/bin
