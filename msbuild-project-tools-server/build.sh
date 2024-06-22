#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
dotnet publish --no-self-contained src/LanguageServer/LanguageServer.csproj --output ${PREFIX}/libexec/${PKG_NAME} 

mkdir -p ${PREFIX}/bin
rm -rf ${PREFIX}/libexec/${PKG_NAME}/NugetUtility
tee ${PREFIX}/bin/msbuild-project-tools-server << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/MSBuildProjectTools.LanguageServer.dll "\$@"
EOF
rm ${PREFIX}/libexec/msbuild-project-tools-server/MSBuildProjectTools.LanguageServer.Host

dotnet-project-licenses -e --input . -f license-files
