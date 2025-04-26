#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Don't install symlink for libdts.a
sed -i '/libdts.a/d' libdca/Makefile.am

# Update symlinks to use compressed man pages
sed -i '/DESTDIR/ s/\.1/.1.gz/g' src/Makefile.am

export ACLOCAL_PATH=${PREFIX}/share/aclocal

autoreconf --force --install --verbose
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
