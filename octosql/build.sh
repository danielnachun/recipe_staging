#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X github.com/cube2222/octosql/cmd.VERSION=${PKG_VERSION}"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
#go-licenses save . --save_path=license-files
mkdir -p ${PREFIX}/etc/bash_completion.d 
mkdir -p ${PREFIX}/share/fish/vendor_completions.d 
mkdir -p ${PREFIX}/share/zsh/site-functions
octosql completion bash > ${PREFIX}/etc/bash_completion.d/octosql
octosql completion fish > ${PREFIX}/share/fish/vendor_completions.d/octosql.fish
octosql completion zsh > ${PREFIX}/share/zsh/site-functions/_octosql
