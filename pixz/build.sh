#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make
make install

#export XML_CATALOG_FILES=${PREFIX}/xml/catalog
#a2x --doctype manpage --format manpage src/pixz.1.asciidoc
#cp src/pixz.1 ${PREFIX}/share/man/man1
