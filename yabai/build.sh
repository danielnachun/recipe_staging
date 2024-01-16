#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make -j1 install

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/${PKG_NAME}
mkdir -p ${PREFIX}/share/man/man1
install -m 755 bin/yabai ${PREFIX}/bin
install -m 644 examples/skhdrc ${PREFIX}/share/${PKG_NAME}
install -m 644 examples/yabairc ${PREFIX}/share/${PKG_NAME}
install -m 644 doc/yabai.1 ${PREFIX}/share/man/man1
