#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export "CFLAGS=${CFLAGS} -fcommon -Wno-incompatible-function-pointer-types"

./configure --disable-debug \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make install

# Delete files that conflict with tar
if [[ ${target_platform} =~ .*linux.* ]]; then
    rm ${PREFIX}/libexec/rmt
    rm ${PREFIX}/share/man/man8/rmt.8
fi

