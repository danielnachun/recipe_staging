##!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -trimpath -buildmode=pie -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" ./cmd/${PKG_NAME}
go-licenses save ./cmd/${PKG_NAME} --save_path=license-files
