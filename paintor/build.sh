#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's?-I/$(curr)/eigen/Eigen??g' Makefile
sed -i 's/causal_index\[i\]-1/static_cast<int>(causal_index[i]-1)/g' Functions_model.cpp
make CC="${CXX} -I${PREFIX}/include/eigen3/Eigen -I${PREFIX}/include -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
	
mkdir -p ${PREFIX}/bin
install -m 755 PAINTOR ${PREFIX}/bin
