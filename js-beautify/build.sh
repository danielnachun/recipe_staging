#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
pnpm install

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/css-beautify.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\css-beautify %*
EOF

tee ${PREFIX}/bin/html-beautify.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\html-beautify %*
EOF

tee ${PREFIX}/bin/js-beautify.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\js-beautify %*
EOF
