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
tee ${PREFIX}/bin/perlnavigator << EOF
#!/bin/sh
exec node ${PREFIX}/libexec/${PKG_NAME}/server/out/server.js "\$@"
EOF
