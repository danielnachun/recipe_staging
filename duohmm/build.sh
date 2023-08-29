#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export IFLAGS="${CXXFLAGS}"
make VERSION=${PKG_VERSION} LFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -lz -lboost_iostreams -lboost_program_options"

mkdir -p ${PREFIX}/bin
install -m 755 bin/duohmm ${PREFIX}/bin
