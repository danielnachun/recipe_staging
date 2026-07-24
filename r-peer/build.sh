#!/bin/bash

export DISABLE_AUTOBREW=1

rm -rf src/Eigen src/libpeer.so
echo 'LinkingTo: RcppEigen' >> DESCRIPTION
echo 'CXX_STD = CXX14' >> src/Makevars

# shellcheck disable=SC2086
R CMD INSTALL --build . ${R_ARGS}
