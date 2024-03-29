#!/bin/bash

export DISABLE_AUTOBREW=1
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"

rm -rf src/*.o
rm -rf src/*.dll
# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
