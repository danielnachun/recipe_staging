#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

unset GOPATH
export CGO_ENABLED=1
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
go-licenses save . --save_path=license-files --ignore github.com/CodinGame/h2go
