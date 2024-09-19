#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make PREFIX=${PREFIX} FENNEL=${PREFIX}/bin/fennel
make install

tee ${PREFIX}/bin/fennel-ls.cmd << EOF
call %PREFIX%\bin\lua %PREFIX%\bin\fennel-ls %*
EOF
