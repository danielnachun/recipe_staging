#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X 'github.com/tomwright/dasel/internal.Version=${PKG_VERSION}'"
go build -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" ./cmd/dasel
mkdir -p ${PREFIX}/etc/bash_completion.d/dasel
mkdir -p ${PREFIX}/share/fish/vendor_completions.d/dasel.fish
mkdir -p ${PREFIX}/share/zsh/site-functions/_dasel
dasel completion bash > ${PREFIX}/etc/bash_completion.d/dasel
dasel completion fish > ${PREFIX}/share/fish/vendor_completions.d/dasel.fish
dasel completion zsh > ${PREFIX}/share/zsh/site-functions/_dasel
