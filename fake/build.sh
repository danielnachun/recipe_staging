#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
rm -rf src/app/fake-cli/bin/Debug
dotnet tool restore
dotnet paket restore
dotnet publish --no-self-contained src/app/fake-cli/fake-cli.fsproj --output ${PREFIX}/libexec/${PKG_NAME}

rm -rf ${PREFIX}/libexec/${PKG_NAME}/fake-cli
tee ${PREFIX}/bin/fake-cli << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/fake-cli.dll "\$@"
EOF

dotnet-project-licenses -e --input . -f license-files
