#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

yarn install
npm pack --ignore-scripts

npm install -ddd \
    --global \
    --build-from-source \
    --prefix=${PREFIX}/libexec/${PKG_NAME} \
    fsouza-${PKG_NAME}-${PKG_VERSION}.tgz

mkdir -p ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/${PKG_NAME} ${PREFIX}/bin
