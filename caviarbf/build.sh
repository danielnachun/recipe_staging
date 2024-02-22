#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make 
	
mkdir -p ${PREFIX}/bin
install -m 755 caviarbf ${PREFIX}/bin
install -m 755 model_search ${PREFIX}/bin

export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"
cd caviarbf-r-package/caviarbf
rm -rf src/*.o
R CMD INSTALL .
