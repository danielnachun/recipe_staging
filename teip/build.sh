#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export RUSTONIG_DYNAMIC_LIBONIG=1
export RUSTONIG_SYSTEM_LIBONIG=1
cargo install --features oniguruma --locked --root ${PREFIX} --path .

mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/etc/bash_completion.d 
mkdir -p ${PREFIX}/share/fish/vendor_completions.d 
mkdir -p ${PREFIX}/share/zsh/site-functions

install -m 644 man/teip.1 ${PREFIX}/share/man/man1
install -m 644 completion/zsh/_${PKG_NAME} ${PREFIX}/share/zsh/site-functions
install -m 644 completion/fish/${PKG_NAME}.fish ${PREFIX}/share/fish/vendor_completions.d
install -m 644 completion/bash/${PKG_NAME} ${PREFIX}/etc/bash_completion.d

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
