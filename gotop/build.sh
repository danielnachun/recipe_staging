#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" ./cmd/gotop
