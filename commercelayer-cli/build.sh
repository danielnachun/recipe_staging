#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/commercelayer.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\commercelayer %*
EOF

tee ${PREFIX}/bin/cl.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\cl %*
EOF

tee ${PREFIX}/bin/clayer.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\clayer %*
EOF
