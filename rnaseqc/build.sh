#!/usrbin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/realloc(b->data, len)/(unsigned char*)realloc(b->data, len)/' htslib/cram/cram_io.h

make CXX="${CXX} -std=c++14" \
     INCLUDE_DIRS="-I${PREFIX}/include" \
     LIBRARY_PATHS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"

mkdir -p ${PREFIX}/bin
install -m 755 rnaseqc ${PREFIX}/bin
