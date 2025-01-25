#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/"games"/"bin"/' fortune-mod/CMakeLists.txt
sed -i 's/"manpages"/"--basepath",\n$ENV{DOCBOOK_BASE_PATH},\n"manpages"/' fortune-mod/util/FortuneMod/ManPage/Generate/App.pm

export DOCBOOK_BASE_PATH="${BUILD_PREFIX}/share/docbook-xsl"

cmake -S fortune-mod -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DNO_OFFENSIVE=ON \
    -DLOCALDIR=${PREFIX}/share/fortune \
    -DCOOKIEDIR=${PREFIX}/share/fortune \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
