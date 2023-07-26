#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/#include "getcwd.h"//g' lib/xgetcwd.c
sed -i 's/AC_SEARCH_LIBS([RC4]/# AC_SEARCH_LIBS([RC4]/g' m4/acx_with_gssapi.m4
sed -i 's/AM_GNU_GETTEXT_VERSION dnl/AM_GNU_GETTEXT_VERSION(0.21) dnl/g' configure.in

autoreconf -fvi
export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration -Wno-int-conversion"

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --infodir=${PREFIX}/info \
    --mandir=${PREFIX}/man \
    --sysconfdir=${PREFIX}/etc \
    --with-gssapi \
    --disable-pam \
    --enable-encryption \
    --with-external-zlib \
    --enable-case-sensitivity \
    --with-editor=vim \
    ac_cv_func_working_mktime=no

make
make install
