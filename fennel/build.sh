#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/env $(LUA)/lua/' Makefile

make PREFIX=${PREFIX}
make install


tee ${PREFIX}/bin/fennel.cmd << EOF
call %PREFIX%\bin\lua %PREFIX%\bin\fennel %*
EOF
