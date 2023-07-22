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
install -m 644 completions/bash/code-minimap.bash ${PREFIX}/etc/bash_completion.d/code-minimap.bash
install -m 644 completions/fish/code-minimap.fish ${PREFIX}/share/fish/vendor_completions.d/code-minimap.fish
install -m 644 completions/zsh/_code-minimap ${PREFIX}/share/zsh/site-functions/_code-minimap

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
