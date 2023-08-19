#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export LLVM_CONFIG=${BUILD_PREFIX}/bin/llvm-config
export CRYSTAL_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"
export CRYSTAL_LIBRARY_RPATH="${PREFIX}/lib"

shards install
crystal build ./src/crystalline.cr \
    --release \
    --no-debug \
    -Dpreview_mt \
    -Duse_libiconv \
    --progress \
    --stats \
    --time \
    -o crystalline

mkdir -p ${PREFIX}/bin
install -m 755 crystalline ${PREFIX}/bin
