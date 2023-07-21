#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

cd src
make

mkdir -p ${PREFIX}/bin
install -m 755 torus ${PREFIX}/bin/torus
