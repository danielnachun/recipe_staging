#!/bin/bash

export GTEXTUTILS_CFLAGS="-I $PREFIX/include/gtextutils"
export GTEXTUTILS_LIBS="$PREFIX/lib/libgtextutils.a"
export CXXFLAGS="${CXXFLAGS} -std=c++11 -Wall -Wno-implicit-fallthrough"
export CFLAGS="${CFLAGS} -Wno-error=unused-but-set-variable"
sed -i.bak 's/#pragma pack(1)//g' src/libfastx/fastx.h

if [ "$(uname)" == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    #MACOSX_DEPLOYMENT_TARGET=10.7
    CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
fi

autoreconf --force --verbose --install
./configure --prefix=$PREFIX
make
make install
