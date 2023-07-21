#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build -G Ninja \
    -DCMAKE_ICU_EXTENSIONS=1 \
    -DCMAKE_JSON_EXTENSION=1 \
    -DBUILD_PARQUET_EXTENSION=1 \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF

cmake --build build
cmake --install build

ln -sf ${PREFIX}/bin/duckdb ${PREFIX}/bin/duckdb_cli
