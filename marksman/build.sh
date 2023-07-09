#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export LD_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"

rm global.json
dotnet tool restore

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
case ${target_platform} in 
    osx-64 )
        dotnet publish --no-self-contained --configuration Darwin Marksman/Marksman.fsproj --output bin --runtime osx-x64
        cp -r bin/* ${PREFIX}/libexec/${PKG_NAME} ;;
    osx-arm64 )
        dotnet publish --no-self-contained --configuration Darwin Marksman/Marksman.fsproj --output bin --runtime osx-arm64
        cp -r bin/* ${PREFIX}/libexec/${PKG_NAME} ;;
    linux-64 )
        dotnet publish --no-self-contained --configuration Linux Marksman/Marksman.fsproj --output bin --runtime linux-x64
        cp -r bin/* ${PREFIX}/libexec/${PKG_NAME} ;;
    linux-arm64 )
        dotnet publish --no-self-contained --configuration Linux Marksman/Marksman.fsproj --output bin --runtime linux-arm64
        cp -r bin/* ${PREFIX}/libexec/${PKG_NAME} ;;
esac

mkdir -p ${PREFIX}/bin
cat << EOF > ${PREFIX}/bin/${PKG_NAME}
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME} "\$@"
EOF
