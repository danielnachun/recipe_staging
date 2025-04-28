#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

tee CMakeLists.txt << EOF
cmake_minimum_required(VERSION 3.5)
project(alglib VERSION ${PKG_VERSION})

file(GLOB SRCS src/*.cpp)
file(GLOB HEADERS src/*.h)

add_library(alglib_static STATIC \${SRCS})
set_target_properties(alglib_static PROPERTIES
    OUTPUT_NAME alglib
    PUBLIC_HEADER "\${HEADERS}"
)

add_library(alglib SHARED \${SRCS})
set_target_properties(alglib PROPERTIES
    VERSION "\${PROJECT_VERSION}"
    SOVERSION "\${PROJECT_VERSION_MAJOR}"
    PUBLIC_HEADER "\${HEADERS}"
)

include(GNUInstallDirs)
install(TARGETS alglib alglib_static
    LIBRARY DESTINATION "\${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "\${CMAKE_INSTALL_LIBDIR}"
    PUBLIC_HEADER DESTINATION "\${CMAKE_INSTALL_INCLUDEDIR}/libalglib"
)
install(FILES manual.cpp.html DESTINATION "\${CMAKE_INSTALL_DOCDIR}")
EOF

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
