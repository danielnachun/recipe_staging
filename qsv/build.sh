#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export CXXFLAGS="${CXXFLAGS} -include stdint.h"
if [[ ${target_platform} =~ .*osx.* ]]; then
    export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
fi
cargo install --features all_features --locked --root ${PREFIX} --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
