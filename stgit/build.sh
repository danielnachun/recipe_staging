#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path .
mkdir -p ${PREFIX}/etc/bash_completion.d 
mkdir -p ${PREFIX}/share/fish/vendor_completions.d 
mkdir -p ${PREFIX}/share/zsh/site-functions
stg completion bash > ${PREFIX}/etc/bash_completion.d/stg
stg completion fish > ${PREFIX}/share/fish/vendor_completions.d/stg.fish
stg completion zsh > ${PREFIX}/share/zsh/site-functions/_stg

# strip debug symbols
"$STRIP" "$PREFIX/bin/stg"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"

make -C contrib prefix=${PREFIX} all
