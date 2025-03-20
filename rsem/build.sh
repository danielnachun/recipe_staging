#!/usr/bin/bash
set -x

case `uname` in
    Linux)
	DSOSUF="so"
	;;
    Darwin)
	DSOSUF="dylib"
	;;
    *)
	echo "Unknown uname '`uname`'" >&2
	exit 1
esac

# Delete vendored boost
rm -rf ./boost

# main binaries
make \
    CXX=$CXX \
    CXXFLAGS="$CXXFLAGS" \
    CPPFLAGS="$CPPFLAGS -I$PREFIX/include -I." \
    SAMLIBS=$PREFIX/lib/libhts.$DSOSUF \
    SAMHEADERS=$PREFIX/include/htslib/sam.h \
    LDFLAGS="$LDFLAGS -L$PREFIX/lib" \
    BOOST=${PREFIX}/include \
    prefix="$PREFIX" \
    install
