#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" ./cmd/${PKG_NAME}
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 _${PKG_NAME} ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
