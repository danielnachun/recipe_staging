#!/bin/bash

export DISABLE_AUTOBREW=1

sed -i 's/CXX_STD = CXX11/CXX_STD = CXX14/' flashpcaR/src/Makevars
R CMD INSTALL --build flashpcaR ${R_ARGS}
