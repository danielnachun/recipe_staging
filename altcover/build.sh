#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
git remote set-url origin https://github.com/SteveGilham/altcover

framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained AltCover/AltCover.fsproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "netcoreapp2.1"
rm ${PREFIX}/libexec/${PKG_NAME}/AltCover

# Create bash and batch wrappers
tee ${PREFIX}/bin/dotnet-script << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/dotnet-script/AltCover.dll "\$@"
EOF

tee ${PREFIX}/bin/dotnet-script.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\dotnet-script\AltCover.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
# tee ignored_packages.json << EOF
# ["Microsoft.DotNet.PlatformAbstractions"]
# EOF
# dotnet-project-licenses --input src/Dotnet.Script/Dotnet.Script.csproj -t -d license-files -ignore ignored_packages.json
dotnet-project-licenses --input AltCover/AltCover.fsproj -t -d license-files
