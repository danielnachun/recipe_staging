#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export SETUPTOOLS_USE_DISTUTILS=stdlib
export HAVE_CXX=yes
export CFLAGS="-Wno-int-conversion"
export GTKDOCIZE=echo

autoreconf --force --verbose --install
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --disable-silent-rules \
    --without-valgrind \
    --without-lua \
    --without-ruby \
    --without-perl \
    --without-swig \
    --without-python2 
make
make install
