#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
rm -rf paket.lock
sed -i 's/net5.0/net7.0/g' src/FSharpLint.Console/FSharpLint.Console.fsproj
sed -i 's/net5.0/net7.0/g' src/FSharpLint.Core/FSharpLint.Core.fsproj
dotnet tool restore
dotnet fake build
dotnet publish --no-self-contained src/FSharpLint.Console/FSharpLint.Console.fsproj --output ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/dotnet-fsharplint << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/dotnet-fsharplint "\$@"
EOF
