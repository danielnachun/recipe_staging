#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Select the BLAS/LAPACK backend: Intel MKL on linux-64 (where the mkl
# package is available), OpenBLAS everywhere else. CMakeLists.txt uses MKL
# only when MKLROOT is passed with a non-empty value.
if [[ ${target_platform} == "linux-64" ]]; then
    export MKL_THREADING_LAYER="GNU"
    CMAKE_ARGS="${CMAKE_ARGS} -DMKLROOT=${PREFIX}"
fi

# The CMakeLists patch references ${CMAKE_PREFIX_PATH}/include for the devendored
# headers, but rattler-build locates host packages via CMAKE_FIND_ROOT_PATH and
# leaves CMAKE_PREFIX_PATH unset. Point it at the host prefix so that resolves to
# $PREFIX/include (host headers also arrive via the -isystem flag the patched
# CMakeLists now preserves by appending to, not overwriting, CMAKE_CXX_FLAGS).
cmake -S "${SRC_DIR}" -B build \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  ${CMAKE_ARGS}

cmake --build build --target install -j "${CPU_COUNT}"
