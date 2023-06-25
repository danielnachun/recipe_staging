#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./autogen.sh --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --sysconfdir=${PREFIX}/etc \
    --with-experimental
make install
sed -i "s?/usr/local?${PREFIX}?g" ${PREFIX}/sbin/airodump-ng-oui-update
