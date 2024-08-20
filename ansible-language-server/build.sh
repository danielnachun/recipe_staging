#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
sed -i '/prepare/d' package.json
sed -i '/prepack/d' package.json
yarn install
pnpm install
pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ansible-${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\ansible-language-server %*
EOF
