#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd src
make CC="${CXX} -I${PREFIX}/include -L${PREFIX}/lib"
	
install -D -m 755 fastenloc ${PREFIX}/bin/fastenloc
