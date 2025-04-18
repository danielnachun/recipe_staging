#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm install --ignore-scripts
npm run build

# Run pnpm so that pnpm-licenses can create report
cd packages/cli
pnpm install
pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/packages/cli/${PKG_NAME}-cli-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt
