#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="-isystem $PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cmake -S . -B build \
    -DQUICK_LINT_JS_ENABLE_BENCHMARKS=OFF \
    -DQUICK_LINT_JS_INSTALL_VIM_NEOVIM_TAGS=ON \
    -DQUICK_LINT_JS_USE_BUNDLED_GOOGLE_BENCHMARK=OFF \
    -DQUICK_LINT_JS_USE_BUNDLED_GOOGLE_TEST=OFF \
    -DQUICK_LINT_JS_USE_BUNDLED_SIMDJSON=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
