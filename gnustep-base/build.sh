#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export OBJCFLAGS="-Wno-int-conversion"

if [[ ${target_platform} =~ .*linux.* ]]; then
    export CC=${BUILD_PREFIX}/bin/clang
    export CXX=${BUILD_PREFIX}/bin/clang++
fi

./configure --disable-debug \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make install \
    GNUSTEP_HEADERS=${PREFIX}/include \
    GNUSTEP_LIBRARY=${PREFIX}/share \
    GNUSTEP_LOCAL_DOC_MAN=${PREFIX}/share/man \
    GNUSTEP_LOCAL_LIBRARIES=${PREFIX}/lib \
    GNUSTEP_LOCAL_TOOLS=${PREFIX}/bin
