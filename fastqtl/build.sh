#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p obj
mkdir -p bin
sed -i 's/cd $(PATH_TABX) && make && cd ..\/../true/g' Makefile

make CXX="${CXX} -std=c++11" \
   RMATH=$PREFIX/lib/R/include \
   LDFLAG_OPT="-L${PREFIX}/lib -O3" 
	
install -m 755 bin/fastQTL ${PREFIX}/bin
