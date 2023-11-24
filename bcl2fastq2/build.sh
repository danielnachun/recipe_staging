#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd src
cmake -S . -B build -DBCL2FASTQ_VERSION="${PKG_VERSION}" \
        -DBCL2FASTQ_SOURCE_DIR="${SRC_DIR}/src" \
        -DBCL2FASTQ_FORCE_STATIC_LINK=OFF \
        -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -Wl,-rpath-link,${PREFIX}/lib -L${PREFIX}/lib -lexslt" \
        ${CMAKE_ARGS}

cmake --build build -- -j ${CPU_COUNT}
cmake --install build
