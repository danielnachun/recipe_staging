#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

#export CGO_ENABLED=0
export LDFLAGS="-s -w -X main.Version=${PKG_VERSION} -X main.BuildDate=$(date +%Y%m%dT%H%M%S)"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" ./cmd/gotop
