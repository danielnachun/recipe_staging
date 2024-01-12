#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*osx.* ]]; then
    export LDFLAGS="${LDFLAGS} -liconv"
fi

#export BOOST_LIB_SUFFIX="mt"
export CXXFLAGS="${CXXFLAGS} -D_OPEN_SOURCE_EXTENDED"
export BOOST_ROOT=${PREFIX}

./autogen.sh
./configure --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --enable-clock \
    --enable-outputs \
    --enable-unicode \
    --enable-visualizer \
    --with-curl \
    --with-taglib
make
make install
