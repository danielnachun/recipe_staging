#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

cat global.json | jq 'del(.sdk)' | jq 'del(.tools)' > global.json.new
rm -rf global.json
mv global.json.new global.json
dotnet publish --no-self-contained src/dotnet-format.csproj --output ${PREFIX}/libexec/${PKG_NAME}

rm -rf ${PREFIX}/libexec/${PKG_NAME}/dotnet-format
tee ${PREFIX}/bin/dotnet-format << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet run ${PREFIX}/libexec/${PKG_NAME}/dotnet-format.dll "\$@"
EOF
