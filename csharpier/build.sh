#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained Src/CSharpier.Cli/CSharpier.Cli.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

rm ${PREFIX}/libexec/${PKG_NAME}/dotnet-csharpier
tee ${PREFIX}/bin/dotnet-csharpier << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet run ${PREFIX}/libexec/${PKG_NAME}/dotnet-csharpier.dll "\$@"
EOF
