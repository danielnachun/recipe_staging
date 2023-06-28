#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm global.json
dotnet tool restore 
dotnet run --project build -t LocalRelease
dotnet tool install --add-source bin/release_as_tool --tool-path ${DOTNET_ROOT}/tools fsautocomplete

ln -sf ${DOTNET_ROOT}/tools/fsautocomplete ${PREFIX}/bin
