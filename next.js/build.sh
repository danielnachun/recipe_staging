#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mv package.json package_old.json
jq 'del(.engines.pnpm)' package_old.json > package.json
pnpm install
pnpm run build

# Run pnpm so that pnpm-licenses can create report
cd packages/next
pnpm install
pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    ${SRC_DIR}/packages/next/next-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt
