#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*osx.* ]]; then
    if [[ ${target_platform} == "osx-64" ]]; then
        arch="x86_64"
    else
        arch="arm64"
    fi
    cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="${arch}" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15
else
    cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Wno-maybe-uninitialized"
fi
cmake --build build --target Luau.LanguageServer.CLI --config Release

mkdir -p ${PREFIX}/bin
install -m 755 build/${PKG_NAME} ${PREFIX}/bin
