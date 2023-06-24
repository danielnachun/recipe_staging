#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --infodir=${PREFIX}/share/info
make install
