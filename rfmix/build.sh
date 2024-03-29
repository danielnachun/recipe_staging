#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i 's/-march=core2//g' Makefile.am
fi

autoreconf --force --install
./configure
make

mkdir -p ${PREFIX}/bin
install -m 755 rfmix ${PREFIX}/bin
install -m 755 simulate ${PREFIX}/bin
