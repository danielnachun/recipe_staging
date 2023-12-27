#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make prefix=${PREFIX} release READLINE_LIBS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib -lreadline -I${PREFIX}/include"
make prefix=${PREFIX} install
make prefix=${PREFIX} install-shared
