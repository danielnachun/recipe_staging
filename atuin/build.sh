#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

export SODIUM_USE_PKG_CONFIG=1
cargo install --locked --root "${PREFIX}" --path .

# strip debug symbols
"${STRIP}" "${PREFIX}/bin/atuin"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
