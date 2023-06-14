#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/yq -ldflags="-s -w"
mkdir -p ${PREFIX}/etc/bash_completion.d 
mkdir -p ${PREFIX}/share/fish/vendor_completions.d 
mkdir -p ${PREFIX}/share/zsh/site-functions 
mkdir -p ${PREFIX}/share/man/man1
yq shell-completion bash > ${PREFIX}/etc/bash_completion.d/yq
yq shell-completion fish > ${PREFIX}/share/fish/vendor_completions.d/yq.fish
yq shell-completion zsh > ${PREFIX}/share/zsh/site-functions/_yq

./scripts/generate-man-page-md.sh
./scripts/generate-man-page.sh
install -m 644 yq.1 ${PREFIX}/share/man/man1
