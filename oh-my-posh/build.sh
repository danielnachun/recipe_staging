#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X main.Version=${PKG_VERSION}"

pushd src
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
popd

cp -r themes ${PREFIX}
mkdir -p ${PREFIX}/share/${PKG_NAME}
ln -sf ${PREFIX}/theme ${PREFIX}/share/${PKG_NAME}
