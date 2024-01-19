#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export ACLOCAL_FLAGS="-I ${PREFIX}/share/aclocal"
export LDFLAGS="-liconv"
./autogen.sh
./configure --with-ncurses-include-dir=${PREFIX}/include --enable-maintainer-mode
make

mkdir -p ${PREFIX}/libexec/pinentry-mac
cp -r macosx/pinentry.app ${PREFIX}/libexec/pinentry-mac

tee ${PREFIX}/bin/pinentry-mac << EOF
#!/bin/sh
exec ${PREFIX}/libexec/pinentry-mac/pinentry-mac.app/Contents/MacOS/pinentry-mac "\$@"
EOF
