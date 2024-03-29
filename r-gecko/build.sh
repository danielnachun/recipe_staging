#!/bin/bash

export DISABLE_AUTOBREW=1
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"

rm -rf src/*.o
rm -rf src/*.dll
sed -i 's/$(SHLIB_OPENMP_CXXFLAGS)/$(SHLIB_OPENMP_CXXFLAGS) -Wno-c++11-narrowing/' src/Makevars
# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
