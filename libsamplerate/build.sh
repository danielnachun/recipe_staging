#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build -DBUILD_SHARED_LIBS=ON -DLIBSAMPLERATE_EXAMPLES=OFF -DBUILD_TESTING=OFF ${CMAKE_ARGS} 
cmake --build build
cmake --install build
