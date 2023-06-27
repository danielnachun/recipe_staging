#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm global.json
dotnet publish --no-self-contained --output bin -maxcpucount:1 ILSpy.Xplat.slnf --runtime osx-x64
cp -r bin/* ${PREFIX}/libexec/${PKG_NAME}

ln -sf ${PREFIX}/libexec/${PKG_NAME}/ilasm ${PREFIX}/bin/ilasm
ln -sf ${PREFIX}/libexec/${PKG_NAME}/ildasm ${PREFIX}/bin/ildasm
ln -sf ${PREFIX}/libexec/${PKG_NAME}/ilspycmd ${PREFIX}/bin/ilspycmd
