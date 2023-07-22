#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export GOPATH=${BUILD_PREFIX}
export GO111MODULE=auto
./script/build
mkdir -p ${PREFIX}/bin
install -m 755 ccat ${PREFIX}/bin
