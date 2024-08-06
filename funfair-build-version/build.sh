#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"

ln -sf ${SRC_DIR}/src/FunFair.props ${SRC_DIR}/src/FunFair.BuildVersion
ln -sf ${SRC_DIR}/src/FunFair.props ${SRC_DIR}/src/FunFair.BuildVersion.Detection
ln -sf ${SRC_DIR}/src/FunFair.props ${SRC_DIR}/src/FunFair.BuildVersion.Publishers
ln -sf ${SRC_DIR}/src/FunFair.props ${SRC_DIR}/src/FunFair.BuildVersion.Interfaces

dotnet publish --no-self-contained src/FunFair.BuildVersion/FunFair.BuildVersion.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}" /p:RunAnalyzers=False -c Release
rm ${PREFIX}/libexec/${PKG_NAME}/FunFair.BuildVersion

# Create bash and batch wrappers
tee ${PREFIX}/bin/buildversion << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/${PKG_NAME}/FunFair.BuildVersion.dll "\$@"
EOF

tee ${PREFIX}/bin/buildversion.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\\${PKG_NAME}\FunFair.BuildVersion.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
tee ignored_packages.json << EOF
["Nullable.Extended.Analyzer", "LibGit2Sharp*", "Credfeto.Enumeration.Source.Generation*", "CommandLineParser", "FunFair.CodeAnalysis"]
EOF
dotnet-project-licenses --input src/FunFair.BuildVersion/FunFair.BuildVersion.csproj -t -d license-files -ignore ignored_packages.json
