#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1
pushd src
    make
    install -m 755 aescrypt ${PREFIX}/bin/aescrypt
    install -m 755 aescrypt_keygen ${PREFIX}/bin/aescrypt_keygen
popd
install -m 644 man/aescrypt.1 ${PREFIX}/share/man/man1/aescrypt.1
