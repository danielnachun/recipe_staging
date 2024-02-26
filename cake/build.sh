#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/Cake/Cake.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

rm ${PREFIX}/libexec/${PKG_NAME}/Cake
tee ${PREFIX}/bin/cake << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/Cake.dll "\$@"
EOF
