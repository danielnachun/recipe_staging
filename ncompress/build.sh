#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make
make PREFIX=${PREFIX} install

mv ${PREFIX}/bin/compress ${PREFIX}/bin/compress.lzw
mv ${PREFIX}/bin/uncompress ${PREFIX}/bin/uncompress.lzw
