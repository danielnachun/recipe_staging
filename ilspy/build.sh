#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm global.json
dotnet publish --no-self-contained ICSharpCode.ILSpyCmd/ICSharpCode.ILSpyCmd.csproj --output ${PREFIX}/libexec/${PKG_NAME}
dotnet publish --no-self-contained ICSharpCode.Decompiler/ICSharpCode.Decompiler.csproj --output ${PREFIX}/libexec/${PKG_NAME}
dotnet publish --no-self-contained ICSharpCode.ILSpyX/ICSharpCode.ILSpyX.csproj --output ${PREFIX}/libexec/${PKG_NAME}

rm -rf ${PREFIX}/libexec/${PKG_NAME}/InstrumentationEngine/ubuntu
rm -rf ${PREFIX}/libexec/${PKG_NAME}/InstrumentationEngine/macos
rm -rf ${PREFIX}/libexec/${PKG_NAME}/InstrumentationEngine/alpine
sed -i "s/net6.0/net8.0/" ${PREFIX}/libexec/${PKG_NAME}/ilspycmd.runtimeconfig.json
sed -i "s/6.0.0/8.0.0/" ${PREFIX}/libexec/${PKG_NAME}/ilspycmd.runtimeconfig.json

rm -rf ${PREFIX}/libexec/${PKG_NAME}/ilspycmd
tee ${PREFIX}/bin/ilspycmd << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/ilspycmd.dll "\$@"
EOF
