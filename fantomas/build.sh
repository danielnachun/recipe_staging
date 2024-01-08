#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
dotnet publish --no-self-contained src/Fantomas/Fantomas.fsproj --output ${PREFIX}/libexec/${PKG_NAME}

rm -rf ${PREFIX}/libexec/${PKG_NAME}/fantomas
tee ${PREFIX}/bin/fantomas << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet run ${PREFIX}/libexec/${PKG_NAME}/fantomas.dll "\$@"
EOF
