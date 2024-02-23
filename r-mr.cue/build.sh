#!/bin/bash

export DISABLE_AUTOBREW=1
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"

# shellcheck disable=SC2086
rm -rf src/*.o
rm -rf src/*.so
rm -rf src/*.dll
${R} CMD INSTALL --build . ${R_ARGS}
