#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X github.com/rhysd/actionlint.version=${PKG_VERSION}"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" ./cmd/${PKG_NAME}
ronn man/actionlint.1.ronn
mkdir -p ${PREFIX}/share/man/man1
install -m 644 man/actionlint.1 ${PREFIX}/share/man/man1/man/actionlint.1
