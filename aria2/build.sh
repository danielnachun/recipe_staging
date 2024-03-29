#!/bin/bash

OSX_ARGS=""
if [ "$(uname)" == "Darwin" ]
then
    OSX_ARGS="--with-libgmp"
fi

./configure --prefix=${PREFIX} --with-openssl --with-libz --with-libxml2 \
            --with-libssh2 --with-libcares --with-sqlite3 --enable-libaria2 ${OSX_ARGS}

make -j${CPU_COUNT}
make install
