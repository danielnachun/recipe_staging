#!/bin/bash

sed -i 's/CXX11/CXX14/' src/Makevars
export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
R CMD INSTALL --build . ${R_ARGS}
