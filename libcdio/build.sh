#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export ACLOCAL_PATH=${PREFIX}/share/aclocal

autoreconf --force --install --verbose
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --sysconfdir=${PREFIX}/etc \
    --localstatedir=${PREFIX}/var \
    --disable-cddb \
    --enable-cpp-progs \
    --enable-maintainer-mode \
    --disable-static \
    --disable-vcd-info
make install
