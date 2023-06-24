#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X main.Version=v${PKG_VERSION}"
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" "filippo.io/age/cmd/..."

install -m 644 doc/age.1 ${PREFIX}/share/man/man1/age.1
install -m 644 doc/age-keygen.1 ${PREFIX}/share/man/man1/age-keygen.1
