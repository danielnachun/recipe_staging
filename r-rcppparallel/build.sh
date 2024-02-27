#!/usr/bin/env bash 

export TBB_INC=${PREFIX}/include
export TBB_LIB=${PREFIX}/lib
export TBB_USE_SYMLINKS=FALSE
export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
