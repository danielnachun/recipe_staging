#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build -G Ninja \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    ${CMAKE_ARGS}
cmake --build build
ctest -V --test-dir build
cmake --install build
