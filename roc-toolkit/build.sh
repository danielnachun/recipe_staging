#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

scons CC=${CC} CXX=${CXX} \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --enable-examples \
    --enable-tests

scons CC=${CC} CXX=${CXX} \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --enable-examples \
    --enable-tests \
    install
