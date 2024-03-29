#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/shfmt -ldflags="${LDFLAGS}" ./cmd/shfmt
go-licenses save ./cmd/shfmt --save_path=license-files
