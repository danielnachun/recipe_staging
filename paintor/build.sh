#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd nlopt-2.4.2
./configure --prefix="$SRC_DIR"
make
make install

cd ..
make 
	
mkdir -p ${PREFIX}/bin
install -D -m 755 PAINTOR ${PREFIX}/bin
