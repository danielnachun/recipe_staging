#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pnpm install
pnpm run build

# Run pnpm so that pnpm-licenses can create report
cd packages/create-remix
pnpm install
pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/packages/create-remix/create-remix-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt
