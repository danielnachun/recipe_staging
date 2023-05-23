#!/usrbin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd rnaseqc
#sed -i "s?\$(CC)?-I${PREFIX}/include \$(INCLUDE_DIRS)?g" Makefile
#$(STDLIB)
#sed -i "s?\$(INCLUDE_DIRS)?-I${PREFIX}/include \$(INCLUDE_DIRS)?g" Makefile
sed -i 's/CC/CXX/g' Makefile
sed -i "s?-lz?-L${PREFIX}/lib -lz?g" SeqLib/bwa/Makefile
sed -i "s?-lz?-L${PREFIX}/lib -lz?g" SeqLib/fermi-lite/Makefile
make CXX=${CXX} \
     CC="${CC} -fcommon" \
     STDLIB="-std=c++14 -I${PREFIX}/include" \
     INCLUDES="-I${PREFIX}/include" \
     LDFLAGS="-L${PREFIX}/lib" \
     CPPFLAGS="-I${PREFIX}/include" \
     LIBRARY_PATHS="-L${PREFIX}/lib"

install -D -m 755 rnaseqc ${PREFIX}/bin
