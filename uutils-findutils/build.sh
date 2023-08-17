#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

export LIBCLANG_PATH=${BUILD_PREFIX}/lib
export RUSTONIG_DYNAMIC_LIBONIG=1
# build statically linked binary with Rust
cargo install --locked --root ${PREFIX}/libexec --path .

mkdir -p ${PREFIX}/bin
ls ${PREFIX}/libexec/bin | xargs -I % bash -c "ln -sf ${PREFIX}/libexec/bin/% ${PREFIX}/bin/u%"
