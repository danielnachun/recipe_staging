#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/jsonnet -ldflags="${LDFLAGS}" ./cmd/jsonnet
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/jsonnetfmt -ldflags="${LDFLAGS}" ./cmd/jsonnetfmt
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/jsonnet-lint -ldflags="${LDFLAGS}" ./cmd/jsonnet-lint
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/jsonnet-deps -ldflags="${LDFLAGS}" ./cmd/jsonnet-deps
go-licenses save . --save_path=license-files
