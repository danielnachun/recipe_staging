#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="$CFLAGS --sysroot $CONDA_BUILD_SYSROOT"
export CXXFLAGS="$CXXFLAGS --sysroot $CONDA_BUILD_SYSROOT"
export LDFLAGS="$LDFLAGS --sysroot $CONDA_BUILD_SYSROOT"
export CPATH="$BUILD_PREFIX/include"
export LIBRARY_PATH="$BUILD_PREFIX/lib"

git init $SRC_DIR
git -C $SRC_DIR config --local user.name "none"
git -C $SRC_DIR config --local user.email "none@example.org"
git -C $SRC_DIR commit --allow-empty -m "dummy commit"

mx --env ce build 
