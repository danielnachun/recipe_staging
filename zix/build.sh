#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

meson --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --buildtype=release \
    --wrap-mode=nofallback \
    build
meson compile -C build -v
meson install -C build
