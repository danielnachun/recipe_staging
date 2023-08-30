#!/bin/bash

export DISABLE_AUTOBREW=1

rm -rf src/*.o
rm -rf src/*.dll
sed -i 's/$(SHLIB_OPENMP_CXXFLAGS)/$(SHLIB_OPENMP_CXXFLAGS) -Wno-c++11-narrowing/' Makevars
# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
