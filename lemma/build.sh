#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Override LDFLAGS exported by conda to remove -dead_stip_dylibs, which breaks MKL linkage
if [[ ${target_platform} =~ .*osx.* ]]; then
    export LDFLAGS="-Wl,-pie -Wl,-headerpad_max_install_names -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"
    export LDFLAGS_LD="-pie -headerpad_max_install_names -rpath,${PREFIX}/lib -L${PREFIX}/lib"
fi

MKL_ARG=""
if [[ ${target_platform} != "osx-arm64" ]]; then
    MKL_ARG=-DMKL_ROOT=${PREFIX}
fi

cmake -S . -B build \
    ${MKL_ARG} \
    ${CMAKE_ARGS} 
cmake --build build

mkdir -p ${PREFIX}/bin
install -m 755 build/lemma_$(echo ${PKG_VERSION} | tr '.' '_') ${PREFIX}/bin/lemma
