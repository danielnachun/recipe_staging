#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
make build
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} cmd/${PKG_NAME}/${PKG_NAME}.go
