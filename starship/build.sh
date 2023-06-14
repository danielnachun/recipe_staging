#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path .
mkdir -p ${PREFIX}/etc/bash_completion.d 
mkdir -p ${PREFIX}/fish/vendor_completions.d 
mkdir -p ${PREFIX}/zsh/site-functions
starship completions bash > ${PREFIX}/etc/bash_completion.d/starship
starship completions fish > ${PREFIX}/fish/vendor_completions.d/starship.fish
starship completions zsh > ${PREFIX}/zsh/site-functions/_starship

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
