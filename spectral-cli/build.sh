#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd packages/cli
npm pack --ignore-scripts

npm install -ddd \
    --global \
    --build-from-source \
    --prefix=${PREFIX}/libexec/${PKG_NAME} \
    stoplight-${PKG_NAME}-${PKG_VERSION}.tgz

mkdir -p ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/spectral ${PREFIX}/bin
