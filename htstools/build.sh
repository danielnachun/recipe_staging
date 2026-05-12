#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

LDFLAGS="${LDFLAGS} -lhts"
if [[ ${target_platform} =~ .*osx.* ]]; then
    LDFLAGS="${LDFLAGS} -largp"
fi

mkdir -p ${PREFIX}/bin
${CXX} -std=c++11 ${CXXFLAGS} snp-pileup.cpp ${LDFLAGS} -lhts -o ${PREFIX}/bin/snp-pileup
${CXX} -std=c++11 ${CXXFLAGS} dnafrags.cpp ${LDFLAGS} -lhts -o ${PREFIX}/bin/dnafrags
${CXX} -std=c++11 ${CXXFLAGS} ppflag-fixer.cpp ${LDFLAGS} -lhts -o ${PREFIX}/bin/ppflag-fixer
