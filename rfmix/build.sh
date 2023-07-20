#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

autoreconf --force --install
./configure
make

mkdir -p ${PREFIX}/bin
install -m 755 rfmix ${PREFIX}/bin
install -m 755 simulate ${PREFIX}/bin
