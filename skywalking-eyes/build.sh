#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X github.com/apache/skywalking-eyes/commands.version=${PKG_VERSION}"

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" ./cmd/license-eye
mkdir -p ${PREFIX}/etc/bash_completion.d 
mkdir -p ${PREFIX}/share/fish/vendor_completions.d 
mkdir -p ${PREFIX}/share/zsh/site-functions
skywalking-eyes completion bash > ${PREFIX}/etc/bash_completion.d/skywalking-eyes
skywalking-eyes completion fish > ${PREFIX}/share/fish/vendor_completions.d/skywalking-eyes.fish
skywalking-eyes completion zsh > ${PREFIX}/share/zsh/site-functions/_skywalking-eyes
