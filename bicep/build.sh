#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
git remote set-url origin https://github.com/Azure/bicep

dotnet publish --no-self-contained src/Bicep.Cli/Bicep.Cli.csproj --output ${PREFIX}/libexec/${PKG_NAME} -p:PublishTrimmed=false
dotnet publish --no-self-contained src/Bicep.LangServer/Bicep.LangServer.csproj --output ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bicep ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/Bicep.LangServer ${PREFIX}/bin

tee ignored_packages.json << EOF
["CommandLineParser", "Microsoft.AspNet.WebApi.Client", "Microsoft.Graph.Bicep.Types","OmniSharp.Extensions*"]
EOF
dotnet-project-licenses --input src/Bicep.Cli/Bicep.Cli.csproj -t -d license-files_bicep -ignore ignored_packages.json
dotnet-project-licenses --input src/Bicep.LangServer/Bicep.LangServer.csproj -t -d license-files_bicep-langserver -ignore ignored_packages.json
