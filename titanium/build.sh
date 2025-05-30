#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/titanium.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\titanium %*
EOF

tee ${PREFIX}/bin/ti.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\ti %*
EOF
