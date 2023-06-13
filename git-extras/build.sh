#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make PREFIX=${PREFIX} install
mkdir -p ${PREFIX}/share/${PKG_NAME}/git-extras-completion.zsh
install -m 644 etc/git-extras-completion.zsh ${PREFIX}/share/${PKG_NAME}/git-extras-completion.zsh
