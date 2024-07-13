#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm install
npm run build

mkdir -p dist
cp -r extension/*.js dist

npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --install-links \
    ${PKG_NAME}-${PKG_VERSION}.tgz
cp -r debugger/*.lua ${PREFIX}/lib/node_modules/${PKG_NAME}/debugger

tee ${PREFIX}/bin/local-lua-dbg << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/lib/node_modules/local-lua-debugger-vscode/dist/debugAdapter.js
EOF
