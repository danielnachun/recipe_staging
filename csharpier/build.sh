#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
case ${target_platform} in 
    osx-64 )
        dotnet publish --no-self-contained Src/CSharpier.Cli/CSharpier.Cli.csproj -maxcpucount:1 --output bin --runtime osx-x64 --framework net7.0 ;;
    osx-arm64 )
        dotnet publish --no-self-contained Src/CSharpier.Cli/CSharpier.Cli.csproj -maxcpucount:1 --output bin --runtime osx-arm64 --framework net7.0 ;;
    linux-64 )
        dotnet publish --no-self-contained Src/CSharpier.Cli/CSharpier.Cli.csproj -maxcpucount:1 --output bin --runtime linux-x64 --framework net7.0 ;;
    linux-arm64 )
        dotnet publish --no-self-contained Src/CSharpier.Cli/CSharpier.Cli.csproj -maxcpucount:1 --output bin --runtime linux-arm64 --framework net7.0 ;;
esac

cp -r bin/* ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/dotnet-csharpier << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/dotnet-csharpier "\$@"
EOF
