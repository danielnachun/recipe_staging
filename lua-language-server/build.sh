#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS=-std=c++11

pushd 3rd/luamake
    compile/build.sh 
popd
3rd/luamake/luamake rebuild

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/libexec/${PKG_NAME}/bin 
mkdir -p ${PREFIX}/libexec/log 
mkdir -p ${PREFIX}/bin
install -m 755 bin/lua-language-server ${PREFIX}/libexec/${PKG_NAME}/bin
install -m 755 bin/main.lua ${PREFIX}/libexec/${PKG_NAME}/bin
install -m 644 main.lua ${PREFIX}/libexec/${PKG_NAME}
install -m 644 debugger.lua ${PREFIX}/libexec/${PKG_NAME}
cp -r locale ${PREFIX}/libexec/${PKG_NAME}
cp -r meta ${PREFIX}/libexec/${PKG_NAME}
cp -r script ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/lua-language-server ${PREFIX}/bin
