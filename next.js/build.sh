#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
# pnpm install
# pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    ${SRC_DIR}/next-${PKG_VERSION}.tgz

# Create license report for dependencies
# pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt