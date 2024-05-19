#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i "s/net7.0/net${framework_version}/" src/NugetUtility.csproj
dotnet publish --no-self-contained src/NugetUtility.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

mkdir -p ${PREFIX}/bin
rm -rf ${PREFIX}/libexec/${PKG_NAME}/NugetUtility
tee ${PREFIX}/bin/dotnet-project-licenses << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/NugetUtility.dll "\$@"
EOF

chmod +x ${PREFIX}/bin/dotnet-project-licenses

${PREFIX}/bin/dotnet-project-licenses -e --input . -f license-files
