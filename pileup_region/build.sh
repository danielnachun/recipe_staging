#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

if [[ ${target_platform} =~ .*osx.* ]]; then
    export CFLAGS="-Wno-implicit-function-declaration"
    # HACK - clang -print-resource-dir returns the wrong directory on macOS for some reason
    export RUSTFLAGS="-L${BUILD_PREFIX}/lib/clang/16.0.6/lib/darwin"
fi

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/pileup_region"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
