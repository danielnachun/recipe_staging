#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm install
npm run compile
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --install-links \
    ${PKG_NAME}-${PKG_VERSION}.tgz

tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/lib/node_modules/perl-debug-adapter/out/debugAdapter.js
EOF
