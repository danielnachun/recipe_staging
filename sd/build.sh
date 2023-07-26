#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"

fingerprint_dir=$(ls target/**/release/build | grep "sd\-" | head -n 1)
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/man/man1
install -m 644 $(find . -name sd.bash) ${PREFIX}/etc/bash_completion.d/sd.bash
install -m 644 $(find . -name sd.fish) ${PREFIX}/share/fish/vendor_completions.d/sd.fish
install -m 644 $(find . -name _sd) ${PREFIX}/share/zsh/site-functions/_sd
install -m 644 $(find . -name sd.1) ${PREFIX}/share/man/man1/sd.1
