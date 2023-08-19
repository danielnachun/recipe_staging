#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PATH="${PATH}:${SRC_DIR}/boot/bin"
export LLVM_CONFIG=${BUILD_PREFIX}/bin/llvm_config
export CRYSTAL_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"
sed -i "s/&& !flag?(:darwin)//" src/crystal/main.cr

mkdir -p .build
make install release=true FLAGS="--no-debug -D use_libiconv" interpreter=true PREFIX=${PREFIX}
install -m 644 src/llvm/ext/llvm_ext.o ${PREFIX}/share/crystal/src/llvm/ext
