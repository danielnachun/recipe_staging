#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X main.Version=${PKG_VERSION}"

pushd src
    go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
    go-licenses save . --save_path=../license-files \
        --ignore github.com/golang/freetype/raster \
        --ignore github.com/golang/freetype/truetype \
        --ignore github.com/jandedobbeleer/oh-my-posh \
        --ignore github.com/mattn/go-localereader
popd

cp -r themes ${PREFIX}
mkdir -p ${PREFIX}/share/${PKG_NAME}
ln -sf ${PREFIX}/theme ${PREFIX}/share/${PKG_NAME}
