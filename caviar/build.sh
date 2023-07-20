#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd CAVIAR-C++
make CC="${CXX} -std=c++11 -I${PREFIX}/include -L${PREFIX}/lib"
	
mkdir -p ${PREFIX}/bin
install -m 755 CAVIAR ${PREFIX}/bin
install -m 755 eCAVIAR ${PREFIX}/bin
install -m 755 setCAVIAR ${PREFIX}/bin
install -m 755 mupCAVIAR ${PREFIX}/bin
