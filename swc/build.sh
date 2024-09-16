#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# sed -i 's/"-Zshare-generics=y"\|"-Zshare-generics=y",//g' .cargo/config.toml
rm .cargo/config.toml
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export RUSTC_BOOTSTRAP=1
cargo install --no-track --locked --root ${PREFIX} --path crates/swc_cli_impl

# strip debug symbols
"$STRIP" "$PREFIX/bin/$PKG_NAME"
