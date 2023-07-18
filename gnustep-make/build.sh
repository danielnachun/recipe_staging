#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --with-config-file=${PREFIX}/etc/GNUstep.conf \
    --enable-native-objc-exceptions

make install tooldir=${PREFIX}/bin
