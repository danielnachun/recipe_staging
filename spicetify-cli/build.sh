#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/libexec/${PKG_NAME}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
cp css-map.json ${PREFIX}/libexec/${PKG_NAME}
cp -R CustomApps ${PREFIX}/libexec/${PKG_NAME}
cp -R Extensions ${PREFIX}/libexec/${PKG_NAME}
cp globals.d.ts ${PREFIX}/libexec/${PKG_NAME}
cp -R jsHelper ${PREFIX}/libexec/${PKG_NAME}
cp -R Themes ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/spicetify-cli ${PREFIX}/bin/spicetify-cli

#go-licenses save . --save_path=license-files
