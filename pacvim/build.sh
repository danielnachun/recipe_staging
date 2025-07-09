#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/CFLAGS =/CFLAGS +=/' Makefile

make install PREFIX=${PREFIX} \
    CXX="${CXX}" \
    LFLAGS="${LDFLAGS} -lncurses"
