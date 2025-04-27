#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

build_tools=true
if [[ ${target_platform} =~ .*linux.* ]]; then
    build_tools=false
fi

meson --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --buildtype=release \
    --wrap-mode=nofallback \
    build \
    -D tools=${build_tools} \
    -D python=false
meson compile -C build -v
meson install -C build
