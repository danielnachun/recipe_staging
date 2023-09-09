#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --bin jj --path cli

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
jj util completion --bash > ${PREFIX}/etc/bash_completion.d/jj.bash
jj util completion --zsh > ${PREFIX}/share/zsh/site-functions/_jj
jj util completion --fish > ${PREFIX}/share/fish/vendor_completions.d/jj.fish

mkdir -p ${PREFIX}/share/man/man1
jj util mangen > ${PREFIX}/share/man/man1/jj.1

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
