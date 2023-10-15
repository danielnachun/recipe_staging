#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
rm -rf paket.lock
sed -i 's/net5.0/net7.0/g' src/FSharpLint.Console/FSharpLint.Console.fsproj
sed -i 's/net5.0/net7.0/g' src/FSharpLint.Core/FSharpLint.Core.fsproj
sed -i 's/net5.0/net7.0/g' tests/FSharpLint.Benchmarks/FSharpLint.Benchmarks.fsproj
sed -i 's/net5.0/net7.0/g' tests/FSharpLint.FunctionalTest/FSharpLint.FunctionalTest.fsproj
sed -i 's/net5.0/net7.0/g' tests/FSharpLint.Core.Tests/FSharpLint.Core.Tests.fsproj
sed -i 's/net5.0/net7.0/g' tests/FSharpLint.Console.Tests/FSharpLint.Console.Tests.fsproj
sed -i 's/net5.0/net7.0/g' paket.dependencies
sed -i 's/~> 0.53.0//' paket.dependencies
mv .config/dotnet-tools.json .config/dotnet-tools.json.bak
jq '.tools.paket.version = "7.2.1"' .config/dotnet-tools.json.bak > .config/dotnet-tools.json

dotnet tool restore
dotnet paket install
dotnet publish --no-self-contained src/FSharpLint.Console/FSharpLint.Console.fsproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net7.0

tee ${PREFIX}/bin/dotnet-fsharplint << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/dotnet-fsharplint "\$@"
EOF
