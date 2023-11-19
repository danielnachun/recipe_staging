#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
rm .paket/paket.exe
tee ${SRC_DIR}/.paket/paket.runtimeconfig.json << EOF
{
  "runtimeOptions": {
    "tfm": "netcoreapp2.1",
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "7.0.10"
    }
  }
}
EOF
sed -i 's/$(MonoPath) --runtime=.* "$(PaketExePath)"/"$(PaketExePath)"/' .paket/Paket.Restore.targets

dotnet tool restore
dotnet publish --no-self-contained src/Paket/Paket.fsproj --output ${PREFIX}/libexec/${PKG_NAME} --framework netcoreapp2.1

tee ${PREFIX}/bin/paket << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/paket.dll "\$@"
EOF
