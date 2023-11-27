#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=1
export GO_LDFLAGS="-s -w"
export LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${GO_LDFLAGS}"
go-licenses save . --save_path=license-files --ignore github.com/akitasoftware/plugin-flickr
