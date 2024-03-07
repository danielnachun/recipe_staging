#!/usrbin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/CC/CXX/g' Makefile
#sed -i 's?./configure &&?./autogen.sh && ./configure &&?' Makefile
#sed -i "s?-lz?-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -lz?g" SeqLib/bwa/Makefile
#sed -i "s?-lz?-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -lz?g" SeqLib/fermi-lite/Makefile
sed -i 's?$(foreach file,$(OBJECTS),$(SRCDIR)/$(file)) SeqLib/lib/libseqlib.a SeqLib/lib/libhts.a?$(foreach file,$(OBJECTS),$(SRCDIR)/$(file))?' Makefile
sed -i 's?ar -rcs rnaseqc.a $^?$(CXX) -O3 $(LIBRARY_PATHS) -o librnaseqc$(SHLIB_EXT) $^ $(LIBS)?' Makefile
sed -i 's/realloc(b->data, len)/(unsigned char*)realloc(b->data, len)/' htslib/cram/cram_io.h
sed -i 's/-lpthread/-lpthread -lseqlib -lhts -lbwa/' Makefile

make CXX="${CXX} -std=c++14" \
     INCLUDE_DIRS="-I${PREFIX}/include" \
     LIBRARY_PATHS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"

mkdir -p ${PREFIX}/bin
install -m 755 rnaseqc ${PREFIX}/bin
