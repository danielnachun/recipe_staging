#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

meson --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --buildtype=release \
    --wrap-mode=nofallback \
    build \
    -D tools=true \
    -D python=false
meson compile -C build -v
meson install -C build
