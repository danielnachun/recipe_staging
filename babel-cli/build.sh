#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm run bootstrap
cd packages/babel-cli

# Run pnpm so that pnpm-licenses can create report
pnpm install
pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/packages/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt

tee ${PREFIX}/bin/babel.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\babel %*
EOF

tee ${PREFIX}/bin/babel-external-helpers.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\babel-external-helpers %*
EOF
