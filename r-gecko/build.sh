#!/bin/bash

export DISABLE_AUTOBREW=1

rm -rf src/*.o
rm -rf src/*.dll
# shellcheck disable=SC2086
${R} CMD INSTALL --configure-args="CXXFLAGS=-Wno-c++11-narrowing" --build . ${R_ARGS}
