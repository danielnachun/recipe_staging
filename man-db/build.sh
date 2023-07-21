#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --disable-cache-owner \
    --disable-setuid \
    --disable-nls \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --localstatedir=${PREFIX}/var \
    --with-config-file=${PREFIX}/etc/man_db.conf \
    --with-systemdtmpfilesdir=${PREFIX}/etc/tmpfiles.d \
    --with-systemdsystemunitdir=${PREFIX}/etc/systemd/system

make install

sed -i "s|/var|${PREFIX}/var|g" ${PREFIX}/etc/man_db.conf
