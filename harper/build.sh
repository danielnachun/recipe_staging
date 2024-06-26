#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path harper-cli
cargo install --locked --root ${PREFIX} --path harper-ls

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}-cli"
"$STRIP" "$PREFIX/bin/${PKG_NAME}-ls"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
