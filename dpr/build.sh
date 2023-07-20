#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

arc unarchive DPR.rar
patch -p1 -i ${RECIPE_DIR}/0001-fix-duplicated-symbols.patch
patch -p1 -i ${RECIPE_DIR}/0002-fix-cstdint.patch
cd DPR
make clean
make CPP="${CXX} -I${PREFIX}/include -L${PREFIX}/lib -Wno-narrowing" FORCE_DYNAMIC=1

mkdir -p ${PREFIX}/bin
install -m 755 bin/DPR ${PREFIX}/bin
