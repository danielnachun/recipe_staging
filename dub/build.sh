#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

DMD=ldmd2 ldmd2 -run ./build.d -release -O3
bin/dub --single scripts/man/gen_man.d

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1 
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions

install -m 755 bin/dub ${PREFIX}/bin
install -m 644 scripts/bash-completion/dub.bash ${PREFIX}/etc/bash_completion.d/dub
install -m 644 scripts/fish-completion/dub.fish ${PREFIX}/share/fish/vendor_completions.d
install -m 644 scripts/zsh-completion/_dub ${PREFIX}/share/zsh/site-functions
cp scripts/man/*.1 ${PREFIX}/share/man/man1
