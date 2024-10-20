#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd SEG
mkdir -p ${PREFIX}/bin
sed -i 's/cc/$(CC) $(CFLAGS)/' makefile

export CFLAGS="-Wno-implicit-function-declaration -Wno-implicit-int -Wno-return-mismatch"
rm -rf *.o
rm seg
rm seg.sgi.iris5
rm seg.sun.sunos4
make
make hiseg

install -m 755 seg ${PREFIX}/bin/seg
install -m 755 hiseg ${PREFIX}/bin/hiseg
