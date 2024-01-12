#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

meson --prefix=${PREFIX} --libdir=${PREFIX}/lib --buildtype=release --wrap-mode=nofallback . output
ninja -C output
ninja -C output install
