#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i -e 's/all_done: test_build/all_done:/' \
    -e 's/all_done: test_build/all_done:/' \
    GNUmakefile GNUmakefile.llvm

make -j${CPU_COUNT} PREFIX=${PREFIX} LLVM_BINDIR=${PREFIX}/bin LLVM_LIBDIR=${PREFIX}/lib source-only
make -j${CPU_COUNT} PREFIX=${PREFIX} LLVM_BINDIR=${PREFIX}/bin LLVM_LIBDIR=${PREFIX}/lib test
make -j${CPU_COUNT} PREFIX=${PREFIX} LLVM_BINDIR=${PREFIX}/bin LLVM_LIBDIR=${PREFIX}/lib install
