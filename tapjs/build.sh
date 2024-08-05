#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Bootstrap setup
npm run bootstrap
cd src/tap

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/src/tap/tap-${PKG_VERSION}.tgz

# Run pnpm so that pnpm-licenses can create report
pnpm install --ignore-scripts

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\tap %*
EOF
