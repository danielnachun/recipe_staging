#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin 
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r * ${PREFIX}/libexec/${PKG_NAME}

chmod 755 ${PREFIX}/libexec/${PKG_NAME}/PRScs.py
ln -sf ${PREFIX}/libexec/${PKG_NAME}/PRScs.py ${PREFIX}/bin/PRScs
