#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" ./seqkit
go-licenses save ./seqkit --save_path=license-files \
    --ignore github.com/ajstarks/svgo \
    --ignore github.com/cznic/sortutil \
    --ignore github.com/golang/freetype \
    --ignore github.com/iafan/cwalk
