#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PREFIX=${PREFIX}
export MANPREFIX=${PREFIX}/share/man
./configure
make
make install
