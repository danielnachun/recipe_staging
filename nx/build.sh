#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd packages/nx
# Run pnpm so that pnpm-licenses can create report
pnpm install --ignore-scripts
pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
