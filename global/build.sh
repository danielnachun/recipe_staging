#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --sysconfdir=${PREFIX}/etc \
    --with-ncurses=${PREFIX} \
    --with-sqlite3=${PREFIX} \
    --with-universal-ctags=${PREFIX}/bin/ctags

make install

mkdir -p ${PREFIX}/etc
install -m 644 gtags.conf ${PREFIX}/etc
