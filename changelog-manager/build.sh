#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/Credfeto.ChangeLog.Cmd/Credfeto.ChangeLog.Cmd.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}"
rm ${PREFIX}/libexec/${PKG_NAME}/changelog

# Create bash and batch wrappers
tee ${PREFIX}/bin/changelog << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/changelog/changelog.dll "\$@"
EOF

tee ${PREFIX}/bin/changelog.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\changelog\changelog.dll %*
EOF

# # Download dependency licenses wtih dotnet-project-licenses
# tee ignored_packages.json << EOF
# ["Microsoft.DotNet.PlatformAbstractions"]
# EOF
# dotnet-project-licenses --input src/Dotnet.Script/Dotnet.Script.csproj -t -d license-files -ignore ignored_packages.json
dotnet-project-licenses --input src/Dotnet.Script/Dotnet.Script.csproj -t -d license-files
