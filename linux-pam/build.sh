#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --disable-db \
    --disable-silent-rules \
    --disable-selinux \
    --includedir=${PREFIX}/include/security \
    --oldincludedir=${PREFIX}/include \
    --enable-securedir=${PREFIX}/lib/security \
    --sysconfdir=${PREFIX}/etc \
    --with-xml-catalog=${PREFIX}/etc/xml/catalog \
    --with-libprelude-prefix=${PREFIX}

make
make install
