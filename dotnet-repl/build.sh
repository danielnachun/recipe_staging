#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
dotnet publish --no-self-contained src/dotnet-repl/dotnet-repl.csproj --output ${PREFIX}/libexec/${PKG_NAME} 

rm -rf ${PREFIX}/libexec/${PKG_NAME}/libmi${SHLIB_EXT}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/libpsl-native${SHLIB_EXT}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/libpsrpclient${SHLIB_EXT}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/libSystem.IO.Ports.Native${SHLIB_EXT}
ln -sf ${PREFIX}/lib/libmi${SHLIB_EXT} ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${PREFIX}/lib/libpsl-native${SHLIB_EXT} ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${PREFIX}/libexec/powershell/7/libpsrpclient${SHLIB_EXT} ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${PREFIX}/libexec/powershell/7/libSystem.IO.Ports.Native${SHLIB_EXT} ${PREFIX}/libexec/${PKG_NAME}

rm -rf ${PREFIX}/libexec/${PKG_NAME}/.playwright
rm -rf ${PREFIX}/libexec/${PKG_NAME}/runtimes

tee ${PREFIX}/bin/dotnet-repl << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/dotnet-repl "\$@"
EOF

dotnet-project-licenses -e --input . -f license-files
