#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make

mkdir -p ${PREFIX}/bin 
mkdir -p ${PREFIX}/share/man/man1
install -m 755 members -t ${PREFIX}/bin 
install -m 644 members.1 -t ${PREFIX}/share/man/man1

