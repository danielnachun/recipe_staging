#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make -j${CPU_COUNT} CXX="${CXX} -std=c++0x" \
   BOOST_INC=${PREFIX}/include \
   BOOST_LIB=${PREFIX}/lib \
   RMATH_INC=${PREFIX}/lib/R/include \
   RMATH_LIB=${PREFIX}/lib \
   HTSLD_INC=${PREFIX}/lib/R/include \
   HTSLD_LIB=${PREFIX}/lib \
   prefix=${PREFIX} \
   LIB_FILES="-L${PREFIX}/lib -lRmath -lhts -ldl -lboost_iostreams -lboost_program_options"
	
mkdir -p ${PREFIX}/bin
install -m 755 bin/QTLtools ${PREFIX}/bin
