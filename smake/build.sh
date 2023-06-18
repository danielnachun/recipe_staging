#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make GMAKE_NOWARN=true INS_BASE=${PREFIX} INS_RBASE=${PREFIX} CFLAGS="${CFLAGS} -Wno-implicit-int" install
