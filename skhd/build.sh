#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/-std=c99/-std=c99 -Wno-implicit-function-declaration/' makefile
make -j1 install

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/${PKG_NAME}
install -m 755 bin/skhd ${PREFIX}/bin
install -m 644 examples/skhdrc ${PREFIX}/share/${PKG_NAME}
