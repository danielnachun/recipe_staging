#!/usrbin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd rnaseqc
sed -i 's/CC/CXX/g' Makefile
sed -i 's?./configure &&?./autogen.sh && ./configure &&?' Makefile
sed -i "s?-lz?-L${PREFIX}/lib -lz?g" SeqLib/bwa/Makefile
sed -i "s?-lz?-L${PREFIX}/lib -lz?g" SeqLib/fermi-lite/Makefile
make CXX="${CXX} -std=c++14" \
     CC="${CC} -fcommon" \
     STDLIB="-I${PREFIX}/include" \
     INCLUDES="-I${PREFIX}/include" \
     LDFLAGS="-L${PREFIX}/lib" \
     CPPFLAGS="-I${PREFIX}/include" \
     LIBRARY_PATHS="-L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin
install -m 755 rnaseqc ${PREFIX}/bin
