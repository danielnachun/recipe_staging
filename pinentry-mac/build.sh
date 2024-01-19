#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

autoreconf --force --install --verbose -I ${PREFIX}/share/aclocal
./configure --disable-ncurses --enable-maintainer-mode
make

mkdir -p ${PREFIX}/libexec/pinentry-mac
cp -r macosx/pinentry-mac.app ${PREFIX}/libexec/pinentry-mac

tee ${PREFIX}/bin/pinentry-mac << EOF
#!/bin/sh
exec ${PREFIX}/libexec/pinentry-mac/pinentry-mac.app/Contents/MacOS/pinentry-mac "\$@"
EOF
