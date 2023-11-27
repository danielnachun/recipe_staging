#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go mod vendor
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/2fa -ldflags="${LDFLAGS}"
go-licenses save . --save_path=license-files
