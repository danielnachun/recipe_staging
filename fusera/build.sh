#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go mod init fusera
go mod tidy -e
rm -rf vendor
go build -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=license-files --ignore github.com/jacobsa/fuse --ignore github.com/jmespath/go-jmespath
