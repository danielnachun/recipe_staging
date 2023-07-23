#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s|/usr/local|${PREFIX}|g" neofetch
make install PREFIX=${PREFIX}
