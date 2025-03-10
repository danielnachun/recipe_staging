#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

yarn
yarn build

# Patch package.json to skip some unneeded dependencies
mv package.json package.json.bak
jq 'del(.packageManager)' package.json.bak |
    jq 'del(.dependencies.zlib)' > package.json

if [[ ${target_platform} =~ .*linux.* ]]; then
    mv package.json package.json.bak
    jq 'del(.nativeDependencies."node-mac-auth")' package.json.bak > package.json
fi

npm install
npm run build

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${PKG_NAME}-${PKG_VERSION}.tgz

mv package.json package.json.bak
jq 'del(.devDepenencies)' package.json.bak > package.json

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/dcli.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\dcli %*
EOF

# Hack for rattler issue
rm -rf ${PREFIX}/lib/node_modules/@dashlane/cli/node_modules/node-mac-auth/build/Release/obj.target
rm -rf ${PREFIX}/lib/node_modules/@dashlane/cli/node_modules/better-sqlite3/build/Release/obj.target
