#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make typical CC="$CC ${CFLAGS} ${LDFLAGS}" \
    CXX="$CXX ${CXXFLAGS} ${LDFLAGS}" \
    BINDIR="${PREFIX}/bin" \
    DISTDIR="${PREFIX}/bin" \
    DIST_DIR="${PREFIX}/bin" \
    JPARALLEL=${CPU_COUNT} \
    SFLAGS= \
    LOCALBZIP2LIB="-lbz2" \
    LOCALZLIBLIB="-lz" \
    LOCALJANSSONLIB="-ljansson" 
make megarow CC="$CC ${CFLAGS} ${LDFLAGS}" \
    CXX="$CXX ${CXXFLAGS} ${LDFLAGS}" \
    BINDIR="${PREFIX}/bin" \
    DISTDIR="${PREFIX}/bin" \
    DIST_DIR="${PREFIX}/bin" \
    JPARALLEL=${CPU_COUNT} \
    SFLAGS= \
    LOCALBZIP2LIB="-lbz2" \
    LOCALZLIBLIB="-lz" \
    LOCALJANSSONLIB="-ljansson" 
make float128 CC="$CC ${CFLAGS} ${LDFLAGS}" \
    CXX="$CXX ${CXXFLAGS} ${LDFLAGS}" \
    BINDIR="${PREFIX}/bin" \
    DISTDIR="${PREFIX}/bin" \
    DIST_DIR="${PREFIX}/bin" \
    JPARALLEL=${CPU_COUNT} \
    SFLAGS= \
    LOCALBZIP2LIB="-lbz2" \
    LOCALZLIBLIB="-lz" \
    LOCALJANSSONLIB="-ljansson" 
install -m 755 applications/other/switch-BEDOPS-binary-type ${PREFIX}/bin
cp -R applications/bed/conversion/src/wrappers/* ${PREFIX}/bin
make symlink_post_install_all BINDIR="${PREFIX}/bin"
#make install_all
#mkdir -p $PREFIX/bin
#cp bin/* $PREFIX/bin
