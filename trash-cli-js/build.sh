#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/trash-cli-${PKG_VERSION}.tgz

tee ${PREFIX}/bin/trash.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\trash %*
EOF
