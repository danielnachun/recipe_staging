#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mv package.json package.json.bak
jq 'del(.scripts.preinstall)' package.json.bak > package.json
npm install --ignore-scripts
npm install yarn@1
npm uninstall tsc
npm install typescript
npm run compile

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\fish-lsp %*
EOF
