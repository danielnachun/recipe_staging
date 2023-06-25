#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path tunnelto
cargo install --locked --root ${PREFIX} --path tunnelto_server

# strip debug symbols
"$STRIP" "$PREFIX/bin/tunnelto"
"$STRIP" "$PREFIX/bin/tunnelto_server"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
