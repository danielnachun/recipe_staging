#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X github.com/git-town/git-town/v7/src/cmd.version=v${PKG_VERSION}"
go build -trimpath -buildmode=pie -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
go-licenses save . --save_path=license-files

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/fish/vendor_completions.d
mkdir -p ${PREFIX}/zsh/site-functions
${PKG_NAME} completions bash > ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
${PKG_NAME} completions fish > ${PREFIX}/fish/vendor_completions.d/${PKG_NAME}.fish
${PKG_NAME} completions zsh > ${PREFIX}/zsh/site-functions/_${PKG_NAME}
