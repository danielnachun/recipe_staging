#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Symlink args.hxx from taywee-args into source tree
mkdir "${SRC_DIR}/src/args"
ln -sf "${BUILD_PREFIX}/include/args.hxx" "${SRC_DIR}/src/args"

export CXXFLAGS="${CXXFLAGS} -I${BUILD_PREFIX}/include -I${BUILD_PREFIX}/include/eigen3" 
make CXX="${CXX}"

mkdir -p ${PREFIX}/bin
install -m 755 bin/apex ${PREFIX}/bin/apex
