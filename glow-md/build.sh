#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X main.Version=${PKG_VERSION}"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/glow -ldflags="${LDFLAGS}"
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader
