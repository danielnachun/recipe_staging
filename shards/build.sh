#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CRYSTAL_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"

make install release=true FLAGS="--no-debug" CRYSTAL=${BUILD_PREFIX}/bin/crystal SHARDS=false PREFIX=${PREFIX}
