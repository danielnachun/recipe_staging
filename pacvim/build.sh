#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/cursesw.h/ncurses.h/' src/globals.h
sed -i 's/cursesw.h/ncurses.h/' src/helperFns.h
sed -i 's/CFLAGS =/CFLAGS +=/' Makefile
export CFLAGS=${CXXFLAGS}

make install PREFIX=${PREFIX} \
    CXX="${CXX}" \
    LFLAGS="${LDFLAGS} -lncurses"
