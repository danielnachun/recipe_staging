#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd extension
npm install
npm run compile
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --install-links \
    go-${PKG_VERSION}.tgz

tee ${PREFIX}/bin/vscode-go-debug-adapter << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/lib/node_modules/go/dist/debugAdapter.js
EOF
