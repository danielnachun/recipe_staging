#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
dotnet publish --no-self-contained "source/Nuke.GlobalTool/Nuke.GlobalTool.csproj" --output ${PREFIX}/libexec/${PKG_NAME}

rm -rf ${PREFIX}/libexec/${PKG_NAME}/Nuke.GlobalTool
tee ${PREFIX}/bin/nuke << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/Nuke.GlobalTool.dll "\$@"
EOF
