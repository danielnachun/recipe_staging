#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

export LIBCLANG_PATH=${BUILD_PREFIX}/lib
export RUSTONIG_DYNAMIC_LIBONIG=1
# build statically linked binary with Rust
cargo install --locked --root ${PREFIX}/libexec/${PKG_NAME} --path .

mkdir -p ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/find ${PREFIX}/bin/ufind
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/xargs ${PREFIX}/bin/uxargs
