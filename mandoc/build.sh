#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cp ${RECIPE_DIR}/configure.local ${SRC_DIR}

tee -a configure.local << EOF
PREFIX="${PREFIX}"
BINDIR="${PREFIX}/bin"
SBINDIR="${PREFIX}/sbin"
MANDIR="${PREFIX}/man"
MISCDIR="${PREFIX}/share/misc"

CC="${CC}"
AR="${AR}"
CFLAGS="${CFLAGS}"
LDFLAGS="${LDFLAGS}"
EOF

cat configure.local

./configure
make install
