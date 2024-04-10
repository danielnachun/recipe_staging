#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/intel64/lp64"
export LDFLAGS=$(echo ${LDFLAGS} | sed 's/-Wl,-dead_strip_dylibs//g')

cd Cpp
sh DoMkl_linux.sh
mkdir -p ${PREFIX}/bin
install -m 755 fastlmmc_mkl ${PREFIX}/bin/fastlmmc
