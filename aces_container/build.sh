#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit


cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_CXX_FLAGS="-Wno-c++11-narrowing"
cmake --build build
cmake --install build
