#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s/-flto//g" Makefile
make CXX="${CXX} -I${PREFIX}/include" LDFLAGS="-L${PREFIX}/lib -lm -lz" CC="${CC} -Wno-overflow"

mkdir -p ${PREFIX}/bin
install -m 755 bin/GAMBIT ${PREFIX}/bin
