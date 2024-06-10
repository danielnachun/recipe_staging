#!/bin/bash

# see https://github.com/conda-forge/r-base-feedstock/issues/163#issuecomment-989515053
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"

export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
