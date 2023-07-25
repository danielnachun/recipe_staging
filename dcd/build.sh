#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make ldc

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/etc
install -m 755 bin/dcd-server ${PREFIX}/bin
install -m 755 bin/dcd-client ${PREFIX}/bin
find man1 -type f -exec install -m 644 "{}" ${PREFIX}/share/man/man1 \;

tee ${PREFIX}/etc/dcd.conf << EOF
    ${PREFIX}/include/dlang/dmd  
EOF
