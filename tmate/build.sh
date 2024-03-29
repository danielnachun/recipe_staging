#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sh autogen.sh

export LDFLAGS="${LDFLAGS} -lresolv"

./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --sysconfdir=${PREFIX}/etc
make install
