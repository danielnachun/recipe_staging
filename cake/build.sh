#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i 's/6.7.0/6.8.1/g' src/Cake.NuGet/Cake.NuGet.csproj
dotnet publish --no-self-contained src/Cake/Cake.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

rm ${PREFIX}/libexec/${PKG_NAME}/Cake
tee ${PREFIX}/bin/cake << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/Cake.dll "\$@"
EOF
