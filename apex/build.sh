#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Symlink args.hxx from taywee-args into source tree
mkdir "${SRC_DIR}/src/args"
ln -sf "${BUILD_PREFIX}/include/args.hxx" "${SRC_DIR}/src/args"

# Disable static linking of libraries
sed -i 's/-static //g' Makefile

make CXX="${CXX} -L${PREFIX}/lib -I${BUILD_PREFIX}/include -I${BUILD_PREFIX}/include/eigen3" 

install -D -m 755 bin/apex ${PREFIX}/bin/apex
