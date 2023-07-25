#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make release
make PREFIX=${PREFIX} install
mkdir -p ${PREFIX}/share/emacs/site-lisp/${PKG_NAME}
mv ${PREFIX}/man/man1/* ${PREFIX}/share/man/man1
rm -rf ${PREFIX}/man/man1
mv ${PREFIX}/man/man3 ${PREFIX}/share/man
mv ${PREFIX}/man/man5 ${PREFIX}/share/man
mv ${PREFIX}/man/man7 ${PREFIX}/share/man
mv ${PREFIX}/share/emacs/site-lisp/*.el ${PREFIX}/share/emacs/site-lisp/${PKG_NAME}
