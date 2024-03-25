#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export EIGEN3_INCLUDE_DIR="${PREFIX}/include/eigen3"
export SPECTRA_LIB="${PREFIX}"
export BOOST_LIB="${PREFIX}"
export MKLROOT="${PREFIX}"

cmake -S . -B build ${CMAKE_ARGS}
cmake --build build
cmake --install build

