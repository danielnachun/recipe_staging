#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

scons --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --enable-examples \
    --enable-tests

scons --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --enable-examples \
    --enable-tests \
    install
