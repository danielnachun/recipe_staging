#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LIBS="${LDFLAGS} -lm -lz -lpthread -Lbwt_gen -lbwtgen"
	
mkdir -p ${PREFIX}/bin
install -m 755 olego ${PREFIX}/bin/olego
