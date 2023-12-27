#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export LD_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"

rm global.json
dotnet tool restore

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
dotnet publish --no-self-contained Marksman/Marksman.fsproj --output ${PREFIX}/libexec/${PKG_NAME}

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME} "\$@"
EOF
