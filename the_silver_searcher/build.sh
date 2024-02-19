#!/usr/bin/env bash

./autogen.sh
# turn clang-format test off: otherwise Mac build gives
#   fatal: not a git repository (or any of the parent directories): .git
# and then hangs forever for some reason
CLANG_FORMAT=no ./configure --prefix="${PREFIX}"
make -j${CPU_COUNT}
make test
make -j${CPU_COUNT} install
