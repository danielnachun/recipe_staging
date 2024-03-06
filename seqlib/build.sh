#!/usrbin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's?../libseqlib.a ../../htslib/libhts.a ../../bwa/libbwa.a ../../fermi-lite/libfml.a?-L../.libs -lseqlib -lhts -lbwa -lfml?' src/seqtools/Makefile.am
sed -i 's/noinst_LIBRARIES = libseqlib.a/lib_LTLIBRARIES = libseqlib.la/' src/Makefile.am
sed -i 's/libseqlib_a/libseqlib_la/' src/Makefile.am
sed -i 's/bwa htslib fermi-lite src/src/' Makefile.am
sed -i 's?src/libseqlib.a fermi-lite/libfml.a bwa/libbwa.a htslib/libhts.a?src/.libs/libseqlib*$(SHLIB_EXT)*?' Makefile.am
sed -i 's?mv seqtools?mv .libs/seqtools?' Makefile.am
echo "LT_INIT(shared)" >> configure.ac

sed -i "s?htslib/htslib?htslib?" src/ReadFilter.cpp
sed -i "s?htslib/htslib?htslib?" SeqLib/BamRecord.h
sed -i "s?htslib/htslib?htslib?" SeqLib/BamHeader.h
sed -i "s?htslib/htslib?htslib?" SeqLib/RefGenome.h

export ACLOCAL_PATH="${PREFIX}/share/aclocal"
autoreconf --force --verbose --install
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make LIBTOOL="${PREFIX}/bin/libtool"
make seqtools LIBTOOL="${PREFIX}/bin/libtool"
make install

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/include
mkdir -p ${PREFIX}/lib

install -m 755 bin/seqtools ${PREFIX}/bin
cp -r lib/* ${PREFIX}/lib
cp -r SeqLib ${PREFIX}/include
