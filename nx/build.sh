#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pnpm install
pnpm run build

cd build/packages/nx
# Run pnpm so that pnpm-licenses can create report
sed -i "s/0.0.1/${PKG_VERSION}/" package.json
pnpm install --ignore-scripts
pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/build/packages/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt
