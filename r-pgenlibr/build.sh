#!/bin/bash

export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
R CMD INSTALL --build . ${R_ARGS}
rm -rf ${PREFIX}/lib/R/library/pgenlibr/include/include/*.o
