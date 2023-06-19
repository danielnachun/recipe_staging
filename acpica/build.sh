#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

declare -a OPT_CFLAGS
if [[ $target_platform =~ .*linux.* ]]; then
    OPT_CFLAGS="-Wno-dangling-pointer"
fi

make PREFIX=${PREFIX} OPT_CFLAGS="${OPT_CFLAGS}"
make PREFIX=${PREFIX} install
