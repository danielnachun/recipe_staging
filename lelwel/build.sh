#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --no-track --locked --root ${PREFIX} --path . --features="cli,lsp"

# strip debug symbols
"$STRIP" "$PREFIX/bin/llw"
"$STRIP" "$PREFIX/bin/lelwel-ls"
