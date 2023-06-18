#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

CFLAGS="${CFLAGS} -D_DARWIN_C_SOURCE"

make PREFIX=${PREFIX} install
