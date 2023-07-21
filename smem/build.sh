#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make smemcap

mkdir -p ${PREFIX}/bin 
mkdir -p ${PREFIX}/share/man/man8
install -m 755 smem -t ${PREFIX}/bin 
install -m 755 smemcap -t ${PREFIX}/bin 
install -m 644 smem.8 -t ${PREFIX}/share/man/man8
