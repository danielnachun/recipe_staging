#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd rnaseq/bamsync
sed -i 's/g++/${CXX}/' Makefile
make CCFLAGS="${CXXFLAGS} -O3 -Wall -Wextra -I${PREFIX}/include/bamtools" LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
install -m 755 bamsync ${PREFIX}/bin
