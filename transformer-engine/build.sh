#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export NVTE_FRAMEWORK="pytorch"
ln -sf ${BUILD_PREFIX}/targets/x86_64-linux/nvvm ${PREFIX}/targets/x86_64-linux
ln -sf ${BUILD_PREFIX}/targets/x86_64-linux/include/fatbinary_section.h ${PREFIX}/targets/x86_64-linux/include

sed -i "s?cmake_flags = \[\"-DCMAKE_CUDA_ARCHITECTURES={}\"?cmake_flags = [\"-DCMAKE_CXX_FLAGS=${CXXFLAGS}\", \"-DCMAKE_CUDA_FLAGS=-isystem ${PREFIX}/include\", \"-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON\", \"-DCMAKE_CUDA_ARCHITECTURES={}\"?" setup.py
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

rm -rf ${PREFIX}/targets/x86_64-linux/nvvm
rm -rf ${PREFIX}/targets/x86_64-linux/include/fatbinary_section.h

mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d
install -m 755 ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d
install -m 755 ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d
