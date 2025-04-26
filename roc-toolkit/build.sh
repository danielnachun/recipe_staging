#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

ln -sf ${CC} ${BUILD_PREFIX}/bin/gcc
ln -sf ${CXX} ${BUILD_PREFIX}/bin/g++

mkdir -p ${PREFIX}/share/man/man1

scons --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --enable-examples \
    --enable-tests

scons --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --enable-examples \
    --enable-tests \
    install
