#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export EIGEN3_INCLUDE_DIR=${PREFIX}/include/eigen3
export BOOST_LIB=${PREFIX}/include

cd scr
make CXX_UNIX=${CXX} LIB="-L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin
install -m 755 gctb ${PREFIX}/bin
