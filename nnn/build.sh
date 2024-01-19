#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*linux.* ]]; then
    sed -i '/#define _FILE_OFFSET_BITS 64/d' src/nnn.c
fi
make install PREFIX=${PREFIX}
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/${PKG_NAME}
install -m 644 misc/auto-completion/bash/nnn-completion.bash ${PREFIX}/etc/bash_completion.d
install -m 644 misc/auto-completion/zsh/_nnn ${PREFIX}/share/zsh/site-functions
install -m 644 misc/auto-completion/fish/nnn.fish ${PREFIX}/share/fish/vendor_completions.d
cp -r misc/quitcd ${PREFIX}/share/${PKG_NAME}
