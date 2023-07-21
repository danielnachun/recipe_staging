#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make CXX="${CXX} -I${PREFIX}/include -L${PREFIX}/lib" CC="${CC} -Wno-overflow"

mkdir -p ${PREFIX}/bin
install -m 755 bin/GAMBIT ${PREFIX}/bin
