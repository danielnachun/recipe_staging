#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path .

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 completions/dust.bash ${PREFIX}/etc/bash_completion.d/dust.bash
install -m 644 completions/dust.fish ${PREFIX}/share/fish/vendor_completions.d/dust.fish
install -m 644 completions/_dust ${PREFIX}/share/zsh/site-functions/_dust

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
