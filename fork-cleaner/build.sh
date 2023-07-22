#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
make
mkdir -p ${PREFIX}/bin
install -m 755 ${PKG_NAME} ${PREFIX}/bin/${PKG_NAME}
