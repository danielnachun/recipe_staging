#!/usr/bin/env bash

if [[ $target_platform =~ linux.* ]]; then
    export CFLAGS="${CFLAGS} -Wno-unused-result -Wno-format-overflow"
else
    export CFLAGS="${CFLAGS} -Wno-unknown-warning-option -Wno-format -Wno-missing-field-initializers"
fi

./configure ac_cv_func_utimensat=no \
    --disable-debug \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make
make install
