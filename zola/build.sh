#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export RUSTONIG_SYSTEM_LIBONIG=1
cargo install --no-track --features native-tls --locked --root ${PREFIX} --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/$PKG_NAME"
