#!/usr/bin/env bash
set -ex

export CFLAGS="${CFLAGS} -U__USE_XOPEN2K -std=c99"
export LDFLAGS=$(echo ${LDFLAGS} | sed 's/-Wl,-dead_strip_dylibs//g')
autoreconf --force --verbose --install

./configure \
  --prefix="${PREFIX}" \
  --enable-svnxx \
  --enable-bdb6 \
  --with-sqlite="${PREFIX}" \
  --disable-static

make -j ${CPU_COUNT}
#make -j ${CPU_COUNT} check CLEANUP=true TESTS=subversion/tests/cmdline/basic_tests.py
make install

if [[ ${target_platform} != "osx-arm64" ]]; then
    make swig-pl-lib
    make install-swig-pl-lib
    pushd subversion/bindings/swig/perl/native
    ${PERL} Makefile.PL INSTALLDIRS=vendor NO_PERLLOCAL=1 NO_PACKLIST=1
    make install
    popd
fi
