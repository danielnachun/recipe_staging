#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
./configure --disable-silent-rules \
    --disable-pinentry-fltk \
    --disable-pinentry-gnome3 \
    --disable-pinentry-gtk2 \
    --disable-pinentry-qt \
    --disable-pinentry-qt5 \
    --disable-pinentry-tqt \
    --enable-pinentry-tty \
    --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib
make install
