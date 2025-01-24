#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i '/AM_C_PROTOTYPES/d' configure.ac
sed -i '/AUTOMAKE_OPTIONS = ansi2knr/d' src/Makefile.am
sed -i '/AUTOMAKE_OPTIONS = ansi2knr/d' src/combine_scm/Makefile.am

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration -Wno-implicit-int"
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make install
