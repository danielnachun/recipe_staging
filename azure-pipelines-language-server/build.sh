#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd language-server
npm pack --ignore-scripts

npm install -ddd \
    --global \
    --build-from-source \
    --prefix=${PREFIX}/libexec/${PKG_NAME} \
    ${PKG_NAME}-${PKG_VERSION}.tgz

mkdir -p ${PREFIX}/bin
