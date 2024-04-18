#!/bin/bash

export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"
rm -rf src/*.o
${R} CMD INSTALL --build . ${R_ARGS}
