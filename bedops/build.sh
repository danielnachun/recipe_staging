#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} == "osx-arm64" ]]; then
    BUILD_ARCH="arm64"
else
    BUILD_ARCH="x86_64"
fi

if [[ ${target_platform} =~ .*linux.* ]]; then
    NCPU=1
else
    NCPU=${CPU_COUNT}
fi

make typical CC="$CC ${CFLAGS} ${LDFLAGS}" \
    CXX="$CXX ${CXXFLAGS} ${LDFLAGS}" \
    BUILD_ARCH="${BUILD_ARCH}" \
    BINDIR="${PREFIX}/bin" \
    DISTDIR="${PREFIX}/bin" \
    DIST_DIR="${PREFIX}/bin" \
    JPARALLEL=${NCPU} \
    SFLAGS= \
    LOCALBZIP2LIB="-lbz2" \
    LOCALZLIBLIB="-lz" \
    LOCALJANSSONLIB="-ljansson" 
make megarow CC="$CC ${CFLAGS} ${LDFLAGS}" \
    CXX="$CXX ${CXXFLAGS} ${LDFLAGS}" \
    BUILD_ARCH="${BUILD_ARCH}" \
    BINDIR="${PREFIX}/bin" \
    DISTDIR="${PREFIX}/bin" \
    DIST_DIR="${PREFIX}/bin" \
    JPARALLEL=${NCPU} \
    SFLAGS= \
    LOCALBZIP2LIB="-lbz2" \
    LOCALZLIBLIB="-lz" \
    LOCALJANSSONLIB="-ljansson" 
make float128 CC="$CC ${CFLAGS} ${LDFLAGS}" \
    CXX="$CXX ${CXXFLAGS} ${LDFLAGS}" \
    BUILD_ARCH="${BUILD_ARCH}" \
    BINDIR="${PREFIX}/bin" \
    DISTDIR="${PREFIX}/bin" \
    DIST_DIR="${PREFIX}/bin" \
    JPARALLEL=${NCPU} \
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
