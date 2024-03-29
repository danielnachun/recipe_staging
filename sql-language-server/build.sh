#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm install --save-dev @types/node
npm pack --ignore-scripts

npm install -ddd \
    --global \
    --build-from-source \
    --prefix=${PREFIX}/libexec/${PKG_NAME} \
    ${PKG_NAME}-${PKG_VERSION}.tgz

mkdir -p ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/sql-language-server ${PREFIX}/bin

rm -rf ${PREFIX}/libexec/${PKG_NAME}/lib/node_modules/sql-language-server/node_modules/sqlite3/build-tmp-napi-v6
