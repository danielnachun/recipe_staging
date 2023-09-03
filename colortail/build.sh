#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./autogen.sh --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
