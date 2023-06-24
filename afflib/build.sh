#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm pyaff/pyaff.c
autoreconf --force --install --verbose
./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX}  \
    --disable-fuse \
    --enable-s3 \
    --enable-python

sed -i "s?--single-version-externally-managed?--install-lib=${PREFIX}/lib/python${PY_VER}/site-packages --single-version-externally-managed?" pyaff/Makefile
make install
