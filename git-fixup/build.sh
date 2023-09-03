#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make install PREFIX=${PREFIX} install

mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
install -m 644 completion.zsh ${PREFIX}/share/zsh/site-functions/_git-fixup
install -m 644 completion.fish ${PREFIX}/share/fish/vendor_completions.d/git-fixup.fish
