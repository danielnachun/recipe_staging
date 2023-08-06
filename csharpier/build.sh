#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
dotnet publish --no-self-contained Src/CSharpier.Cli/CSharpier.Cli.csproj -maxcpucount:1 --output bin --runtime ${target_platform//-64/-x64} --framework net7.0
cp -r bin/* ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/dotnet-csharpier << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/dotnet-csharpier "\$@"
EOF
