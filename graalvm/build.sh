#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

#export CFLAGS="$CFLAGS --sysroot $CONDA_BUILD_SYSROOT"
#export CXXFLAGS="$CXXFLAGS --sysroot $CONDA_BUILD_SYSROOT"
#export LDFLAGS="$LDFLAGS --sysroot $CONDA_BUILD_SYSROOT"
#export CPATH="$BUILD_PREFIX/include"
#export LIBRARY_PATH="$BUILD_PREFIX/lib"

git init $SRC_DIR/graal
git -C $SRC_DIR/graal config --local user.name "none"
git -C $SRC_DIR/graal config --local user.email "none@example.org"
git -C $SRC_DIR/graal commit --allow-empty -m "dummy commit"

export MX_PRIMARY_SUITE_PATH=graal/vm
mx --env ce-darwin build 
