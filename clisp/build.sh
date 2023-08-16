#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export FORCE_UNSAFE_CONFIGURE=1
./configure --disable-debug \
    --disable-silent \
    --disable-dependency-tracking \
    --with-readline=yes \
    --elispdir=${PREFIX}/share/emacs/site-lisp/${PKG_NAME} \
    --prefix=${PREFIX} 

cd src
make
make install
