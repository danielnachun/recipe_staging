#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path .

install -Dm 644 completions/dust.bash ${PREFIX}/etc/bash_completion.d/dust.bash
install -Dm 644 completions/dust.fish ${PREFIX}/share/fish/vendor_completions.d/dust.fish
install -Dm 644 completions/_dust ${PREFIX}/share/zsh/site-functions/_dust

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
