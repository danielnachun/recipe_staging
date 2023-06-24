#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build ${CMAKE_ARGS}
cmake --build build
cmake --install build
