#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Don't use SSE on ARM
if [[ ${target_platform} == "osx-arm64" ]];
    sed -i 's/-mfpmath=sse -msse -msse2//' Makefile.in
fi

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make install
