#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ $target_platform =~ linux.* ]]; then
    export CFLAGS="${CFLAGS} -Wno-unused-result -Wno-format-overflow"
else
    export CFLAGS="${CFLAGS} -Wno-unknown-warning-option -Wno-format -Wno-missing-field-initializers"
fi

# Add missing LDFLAGS for some tests so that all libraries can be found
sed -i 's/${CFLAGS} -D$d/${CFLAGS} ${LDFLAGS} ${LIBS} -D$d/' autoopts/test/defs.in
sed -i 's/${CFLAGS} ${INC} -o ${testname}/${CFLAGS} ${LDFLAGS} ${LIBS} ${INC} -o ${testname}/' autoopts/test/library.test
sed -i 's/CC="${CC} ${CFLAGS} ${INC}"/CC="${CC} ${CFLAGS} ${INC} ${LDFLAGS}"/' autoopts/test/getopt.test

autoreconf --force --install --verbose
sed -i 's/"2.2 2.0 1.8"/"3.0 2.2 2.0 1.8"/' configure
./configure ac_cv_func_utimensat=no \
    --disable-debug \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make
make check
make install
