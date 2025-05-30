#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration -Wno-int-conversion"
if [[ ${target_platform} =~ .*linux.* ]]; then
    export LDFLAGS="${LDFLAGS} -liconv"
    export LDFLAGS="${LDFLAGS/-Wl,--as-needed/}"
fi

autoreconf --force --install --verbose
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --with-freetype-includes=${PREFIX}/include/freetype2 \
    --without-opengl \
    --with-readline \
    --with-pthread \
    --with-netcdf \
    --with-nls \
    --with-geos \
    --with-postgres \
    --with-pdal=${PREFIX}/include/pdal \
    --with-bzlib \
    --with-zstd
make
make install
