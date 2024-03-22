#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

autoreconf --force --verbose --install
./configure --prefix="$PREFIX" \
    --with-tcsetpgrp \
    --enable-fndir=${PREFIX}/share/zsh/functions \
    --enable-scriptdir=${PREFIX}/share/scripts \
    --enable-site-fndir=${PREFIX}/share/zsh/site-functions \
    --enable-site-scriptdir=${PREFIX}/share/zsh/site-scripts \
    --enable-runhelpdir=${PREFIX}/share/zsh/help \
    --enable-cap \
    --enable-maildir-support \
    --enable-multibyte \
    --enable-pcre \
    --enable-zsh-secure-free \
    --enable-unicode9 \
    --enable-etcdir=/etc \
    --with-tcsetpgrp \
    DL_EXT=bundle

make
make check
make install
