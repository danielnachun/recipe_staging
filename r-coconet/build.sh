#!/bin/bash

export DISABLE_AUTOBREW=1

rm -rf src/*.o
rm -rf src/*.so
# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
