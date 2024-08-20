#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
cd lib/server
version="$(jq '.version' package.json | tr -d '\"')"

# Create package archive and install globally
npm install
npm run build
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/lib/server/${PKG_NAME}-${version}.tgz

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\custom-elements-languageserver %*
EOF
