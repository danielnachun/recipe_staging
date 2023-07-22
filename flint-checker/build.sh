#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export GOPATH=${SRC_DIR}
export GO111MODULE=auto
mkdir -p ${SRC_DIR}/src/github.com/pengwynn
ln -sf ${SRC_DIR} ${SRC_DIR}/src/github.com/pengwynn/flint

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
