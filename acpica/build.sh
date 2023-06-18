#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make PREFIX=${PREFIX} CFLAGS="${CFLAGS} -Wno-dangling-pointer"
make PREFIX=${PREFIX} CFLAGS="${CFLAGS} -Wno-dangling-pointer" install
