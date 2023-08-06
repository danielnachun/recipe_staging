#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

build() {
    bin_name=$1
    platform=$2
    dotnet publish --no-self-contained src/Tools/${bin_name}/${bin_name}.csproj --output bin --runtime ${platform}
}

export -f build

env_script() {
bin_name=$1
tee ${PREFIX}/bin/${bin_name} << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/${bin_name} "\$@"
EOF
chmod +x ${PREFIX}/bin/${bin_name}
}

export -f env_script

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

jq 'del(.tool)' < global.json > global.json.new
rm -rf global.json
mv global.json.new global.json
tools=(dotnet-counters dotnet-dsrouter dotnet-dump dotnet-gcdump dotnet-sos dotnet-stack dotnet-trace)

printf "%s\n" "${tools[@]}" | xargs -I % bash -c "build % ${target_platform//-64/-x64}"
cp -r bin/* ${PREFIX}/libexec/${PKG_NAME}
printf "%s\n" "${tools[@]}" | xargs -I % bash -c "env_script %"
