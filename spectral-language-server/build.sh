#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Don't use pre-built gyp packages
export npm_config_build_from_source=true

# source.url in meta.yaml references a tgz file which contains a fully-built package
# version, we now want to turn this back into a tgz file using pnpm pack and install it
# globally from that.
# as we are doing pnpm pack we still need to include the node_modules which we retrieve
# using pnpm install
pnpm install --ignore-scripts

mkdir ../tmp
cd ../tmp
git clone --depth=1 https://github.com/stoplightio/vscode-spectral.git -b v1.1.0 vscode-spectral
cd vscode-spectral
pnpm install
pnpm add @rollup/pluginutils
tsc -p server

cd ${SRC_DIR}
mkdir -p dist
cp -R ../tmp/vscode-spectral/server/dist ./dist/spectral-language-server

pnpm pack

# install package globally from file (as opposed to from a registry as you'd do normally)
NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
npm pack
npm install --ignore-scripts -g ${PKG_NAME}-${PKG_VERSION}.tgz

# generate license disclaimer for the package
# pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
