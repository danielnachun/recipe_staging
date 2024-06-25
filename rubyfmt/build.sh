#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i '1i #![allow(dead_code)]' librubyfmt/src/ripper_tree_types.rs
sed -i '1i #![allow(dead_code)]' librubyfmt/src/parser_state.rs

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
mkdir -p ${PREFIX}/lib
cargo install --locked --root ${PREFIX} --path .

mkdir -p ${PREFIX}/bin
install -m 755 target/**/release/rubyfmt-main ${PREFIX}/bin
ln -sf ${PREFIX}/bin/rubyfmt-main ${PREFIX}/bin/rubyfmt

# strip debug symbols
"$STRIP" "$PREFIX/bin/rubyfmt-main"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
