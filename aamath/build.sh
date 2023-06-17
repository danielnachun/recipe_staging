#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make 
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/share/aamath
install -m 755 aamath ${PREFIX}/bin/aamath
install -m 644 aamath.1 ${PREFIX}/share/man/man1/aamath.1
install -m 644 testcases ${PREFIX}/share/aamath/testcases
