#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*linux.* ]]; then
    export LD_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"
fi

mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm global.json
dotnet tool restore 
dotnet run --project build -t LocalRelease
dotnet tool install --add-source bin/release_as_tool --tool-path ${PREFIX}/libexec/${PKG_NAME} fsautocomplete

ln -sf ${PREFIX}/libexec/${PKG_NAME}/fsautocomplete ${PREFIX}/bin
