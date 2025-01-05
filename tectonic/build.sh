#! /bin/bash

set -ex

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat
export PKG_CONFIG_ALLOW_CROSS=1

# Backport of https://github.com/tectonic-typesetting/tectonic/commit/6b49ca8db40aaca29cb375ce75add3e575558375
cargo add time@0.3.36

sed -i '/-std=c++14",/d' crates/engine_xetex/build.rs

# export CXXFLAGS="${CXXFLAGS} -std=c++17"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --bins --no-track --locked --features external-harfbuzz --root $PREFIX --path .
