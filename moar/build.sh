#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X main.versionString=${PKG_VERSION}"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
go-licenses save . --save_path=license-files
mkdir -p ${PREFIX}/share/man/man1
install -m 644 ${PKG_NAME}.1 ${PREFIX}/share/man/man1/${PKG_NAME}.1
