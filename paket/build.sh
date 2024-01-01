#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
rm .paket/paket.exe
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
tee ${SRC_DIR}/.paket/paket.runtimeconfig.json << EOF
{
  "runtimeOptions": {
    "tfm": "net${framework_version}",
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "${framework_version}.0"
    }
  }
}
EOF
sed -i 's/$(MonoPath) --runtime=.* "$(PaketExePath)"/"$(PaketExePath)"/' .paket/Paket.Restore.targets

sed -i "s?<TargetFrameworks>.*</TargetFrameworks>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" \
     src/Paket/Paket.fsproj
dotnet tool restore
dotnet tool update paket
dotnet publish --no-self-contained src/Paket/Paket.fsproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

tee ${PREFIX}/bin/paket << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/paket.dll "\$@"
EOF
