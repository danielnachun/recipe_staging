#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?-I m4?-I m4 -I ${PREFIX}/share/aclocal?" Makefile.am

autoreconf --force --verbose --install
./configure --prefix="${PREFIX}"
make -j ${CPU_COUNT}
#make -j ${CPU_COUNT} check
make install
