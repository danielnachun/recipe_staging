#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir build
cd build
meson --prefix=${PREFIX} --libdir=${PREFIX}/lib --buildtype=release --wrap-mode=nofallback ..
ninja -v
ninja install -v
