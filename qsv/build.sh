#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

export PATH=$(echo ${PATH} | tr ':' '\n' | grep -v "pixi" | tr '\n' ':')

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export LIBCLANG_PATH="${PREFIX}/lib"
if [[ ${target_platform} =~ .*osx.* ]]; then
    export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
fi

# If we are NOT cross compiling, supply the path to the python interpreter given by ${PYTHON}
# If we are cross compiling, the cross-python package will provide these variables instead.
if [[ ${build_platform} == ${target_platform} ]]; then
    export PYO3_PYTHON=${PYTHON}
fi

export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1
cargo install --features all_features --bins --no-track --locked --root ${PREFIX} --path .
