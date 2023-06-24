#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="-Wno-implicit-function-declaration"
make DESTDIR=${PREFIX}
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1

install -m 755 afio ${PREFIX}/bin/afio
install -m 644 afio.1 ${PREFIX}/share/man/man1/afio.1
cp -r script* ${PREFIX}/share
