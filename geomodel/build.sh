#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's?"fmt/format.h"?<format>?' GeoModelIO/GeoModelDBManager/src/GMDBManager.cpp
sed -i 's?fmt::format?std::format?' GeoModelIO/GeoModelDBManager/src/GMDBManager.cpp

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DCMAKE_CXX_STANDARD=20 \
    -DGEOMODEL_BUILD_TOOLS=ON \
    -DGEOMODEL_BUILD_FSL=ON \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
