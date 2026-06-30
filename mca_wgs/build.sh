#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -O3 -fopenmp -Wall -Wextra -Wno-sign-compare -Wno-unused-local-typedefs -Wno-deprecated -Wno-unused-parameter"
export LDFLAGS="${LDFLAGS} -O3 -fopenmp"

rm -rf obj/*.o
rm -rf bin/*

make CXX=${CXX} all \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    LDLIBS="-lhts -ldeflate -lboost_iostreams -lboost_program_options -lpthread -lz" \
    BFILE=${PREFIX}/bin/mCAs_WGS \
    BOOST_LIB=${PREFIX}/lib \
    BOOST_INC=${PREFIX}/include \
    HTSLD_LIB=${PREFIX}/lib \
    HTSLD_INC=${PREFIX}/include \
    LIBDEFLATE=${PREFIX}/lib \
    EIGEN_INC=${PREFIX}/include/eigen

install -m 755 bin/generateRefMasks ${PREFIX}/bin
install -m 755 bin/countReadsSaveDiscordant ${PREFIX}/bin
install -m 755 bin/computeDepthProfiles ${PREFIX}/bin
install -m 755 bin/computeRegionDepthsPCadj ${PREFIX}/bin
