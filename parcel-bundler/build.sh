#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Patch package.json to remove devDependencies which are not needed for license report
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

rm -rf ${PREFIX}/lib/node_modules/parcel/node_modules/lmdb/build/Release/obj.target
rm -rf ${PREFIX}/lib/node_modules/parcel/node_modules/@parcel/watcher/build/Release/obj.target
rm -rf ${PREFIX}/lib/node_modules/parcel/node_modules/msgpackr-extract/build/Release/obj.target
