#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build_out -G Ninja ${CMAKE_ARGS}
cmake --build build_out
cmake --install build_out
