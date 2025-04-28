#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -DGLOG_USE_GLOG_EXPORT -D_LIBCPP_HAS_NO_ASAN"
if [[ ${target_platform} =~ .*osx.* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,-undefined,dynamic_lookup -Wl,-dead_strip_dylibs"
fi

sed -i 's/compiler_base/shared/g' thrift/shared/CMakeLists.txt
sed -i 's/TARGETS thrift1/TARGETS thrift1\nshared/' thrift/compiler/CMakeLists.txt
sed -i 's?whisker/dsl.cc?whisker/dsl.cc\nwhisker/detail/string.cc?' thrift/compiler/CMakeLists.txt

cmake -S . -B . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_CXX_STANDARD=20 \
    -Dthriftpy3=OFF \
    -Dthriftpy=OFF \
    ${CMAKE_ARGS}

cmake --build . -j${CPU_COUNT}
cmake --install .
