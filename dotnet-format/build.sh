#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

cat global.json | jq 'del(.sdk)' | jq 'del(.tools)' > global.json.new
rm -rf global.json
mv global.json.new global.json
dotnet publish --no-self-contained src/dotnet-format.csproj --output ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/dotnet-format << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/dotnet-format "\$@"
EOF
