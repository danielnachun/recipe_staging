#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release
cmake --build build --target Luau.LanguageServer.CLI --config Release

mkdir -p ${PREFIX}/bin
install -m 755 build/${PKG_NAME} ${PREFIX}/bin
