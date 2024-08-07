#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
pnpm config set '@teambit:registry' https://node-registry.bit.cloud
pnpm config set '@bitdev:registry' https://node-registry.bit.cloud
pnpm install
pnpm pack

# Create package archive and install globally
pnpm install -ddd \
    --global \
    --global-bin-dir ${PREFIX}/bin \
    --global-dir ${PREFIX} \
    ${SRC_DIR}/teambit-bit-${PKG_VERSION}.tgz

# Create license report for dependencies
# pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
