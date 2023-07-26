#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

#patch -Np0 < patches/PR5178707.diff
#patch -Np0 < patches/ea.diff
#patch -Np0 < patches/endian.diff
#patch -Np0 < patches/fixtest-client-20.diff
#patch -Np0 < patches/fixtest-recase.diff
#patch -Np0 < patches/i18n.diff
#patch -Np0 < patches/initgroups.diff
#patch -Np0 < patches/remove-info.diff
#patch -Np0 < patches/tag.diff
#patch -Np0 < patches/zlib.diff
#patch -Np1 < patches/vasnprintf-high-sierra-fix.diff
#patch -Np1 < patches/cvs-1.12.13.1-fix-gnulib-SEGV-vasnprintf.patch?id=6c49fbac47ddb2c42ee285130afea56f349a2d40

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
