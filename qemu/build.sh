#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --prefix=${PREFIX} \
    --cc=${CC} \
    --host-cc=${CC} \
    --disable-bsd-user \
    --disable-guest-agent \
    --enable-slirp \
    --enable-capstone \
    --enable-curses \
    --enable-fdt=system \
    --enable-libssh \
    --enable-vde \
    --enable-virtfs \
    --enable-zstd \
    --extra-cflags=-DNCURSES_WIDECHAR=1 \
    --disable-sdl
make V=1 install

if [[ ${target_platform} =~ .*osx.* ]]; then
    mkdir -p ${PREFIX}/share/${PKG_NAME}
    install -m 644 ${RECIPE_DIR}/entitlements.xml ${PREFIX}/share/${PKG_NAME}
fi
