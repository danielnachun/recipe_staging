#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pnpm install
pnpm run build
cd packages/vitest

# Run pnpm so that pnpm-licenses can create report
pnpm install
pnpm pack

# Create package archive and install globally
pnpm install -ddd \
    --global-bin-dir=${PREFIX}/bin \
    --global-dir=${PREFIX} \
    --global \
    ${SRC_DIR}/packages/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
# pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\vitest %*
EOF
