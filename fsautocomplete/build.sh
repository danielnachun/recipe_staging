#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"

sed -i "s?<TargetFrameworks>.*</TargetFrameworks>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" \
    src/FsAutoComplete/FsAutoComplete.fsproj
sed -i "/TargetFrameworks Condition/d" src/FsAutoComplete/FsAutoComplete.fsproj

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/libexec/${PKG_NAME}"
dotnet tool restore 
dotnet publish --no-self-contained src/FsAutoComplete/FsAutoComplete.fsproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

rm -rf ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}.dll "\$@"
EOF
