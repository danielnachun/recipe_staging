#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --features extra --locked --root ${PREFIX} --path .

install_plugin() {
    plugin_folder=$1
    cd crates/$plugin_folder
    if [[ -f Cargo.toml ]]; then
        cargo install --locked --root ${PREFIX} --path .
    fi
    cd $SRC_DIR
}
export -f install_plugin

ls crates | grep "nu_plugin_" | xargs -I {} bash -c 'install_plugin "{}"'
