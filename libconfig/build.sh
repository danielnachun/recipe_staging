#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

autoupdate
autoreconf --force --install --verbose
./configure --prefix=$PREFIX
make
make check
make install
