#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf bin/*

pushd src
    make Sanity CC="${CXX} -I${PREFIX}/include"
    make Sanity_distance CC="${CXX} -I${PREFIX}/include"
popd ..

mkdir -p ${PREFIX}/bin
install -m 755 bin/Sanity ${PREFIX}/bin
install -m 755 bin/Sanity_distance ${PREFIX}/bin
