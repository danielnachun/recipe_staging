#!/bin/bash

export DISABLE_AUTOBREW=1

sed -i 's/crossprod/base::crossprod/' R/misc.R
sed -i 's/CXX11/CXX14/' src/Makevars

# shellcheck disable=SC2086
R CMD INSTALL --build . ${R_ARGS}
