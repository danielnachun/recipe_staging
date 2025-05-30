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

rm -rf ${PREFIX}/lib/node_modules/netlify-cli/node_modules/sharp/build
rm -rf ${PREFIX}/lib/node_modules/netlify-cli/node_modules/@parcel/watcher/build
rm -rf ${PREFIX}/lib/node_modules/netlify-cli/node_modules/unix-dgram/build

tee ${PREFIX}/bin/netlify.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\netlify %*
EOF

tee ${PREFIX}/bin/ntl.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\ntl %*
EOF
