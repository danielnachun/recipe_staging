#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Fix multiple definition error
sed -i 's/int ROUNDS;/extern int ROUNDS;/' rijndael.h
sed -i 's/#include "rijndael-boxes.dat"/&\nint ROUNDS;/' rijndael.c

export CFLAGS="-Wno-implicit-int"
./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make

mkdir -p ${PREFIX}/bin
install -m 755 aescrypt ${PREFIX}/bin/aescrypt
