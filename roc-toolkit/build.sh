#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

scons --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --enable-examples \
    --enable-tests \
    CC=${CC} \
    CXX=${CXX}

scons --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --enable-examples \
    --enable-tests \
    install
    CC=${CC} \
    CXX=${CXX}
