#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
go run build.go

mkdir -p ${PREFIX}/etc/bash_completion.d 
mkdir -p ${PREFIX}/share/fish/vendor_completions.d 
mkdir -p ${PREFIX}/share/zsh/site-functions 
mkdir -p ${PREFIX}/share/man/man1
./restic generate --bash-completion ${PREFIX}/etc/bash_completion.d/restic
./restic generate --zsh-completion ${PREFIX}/share/zsh/site-functions/_restic
./restic generate --fish-completion ${PREFIX}/share/fish/vendor_completions.d/restic.fish
./restic generate --man ${PREFIX}/share/man/man1

mkdir -p ${PREFIX}/bin
install -m 755 restic ${PREFIX}/bin/restic
