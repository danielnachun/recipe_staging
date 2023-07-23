#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export XML_CATALOG_FILES=${PREFIX}/etc/xml/catalog

make
make install prefix=${PREFIX}

mkdir -p ${PREFIX}/bin
install -m 644 reposurgeon-mode.el ${PREFIX}/share/emacs/site-lisp/reposurgeon-mode.el
