#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm install
npm install --save-dev @types/node
tsc -b
npm pack --ignore-scripts

npm install -ddd \
    --global \
    --build-from-source \
    ${PKG_NAME}-${PKG_VERSION}.tgz

tee ${PREFIX}/bin/perlnavigator << EOF
#!/bin/sh
exec node \${CONDA_PREFIX}/lib/node_modules/perlnavigator-server/out/server.js "\$@"
EOF
