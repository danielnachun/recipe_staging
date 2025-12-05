#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
if [[ ${target_platform} =~ .*osx.* ]]; then
    export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
fi

export PYO3_PYTHON=${PYTHON}
cargo install --features all_features --bins --no-track --locked --root ${PREFIX} --path .
