#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X main.version=${PKG_VERSION}"
go build -mod=mod -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
go-licenses save . --save_path=license-files \
	--ignore github.com/kovetskiy/lorg \
	--ignore github.com/reconquest/nopio-go \
	--ignore github.com/reconquest/prefixwriter-go \
	--ignore github.com/reconquest/runcmd \
	--ignore github.com/zazab/zhash
