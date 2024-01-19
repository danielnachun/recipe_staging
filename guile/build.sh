#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --prefix="${PREFIX}"
make -j ${CPU_COUNT}
#make -j ${CPU_COUNT} check
make install
