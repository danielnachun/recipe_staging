#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
dotnet publish --no-self-contained src/Cake/Cake.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net7.0

tee ${PREFIX}/bin/cake << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/Cake "\$@"
EOF
