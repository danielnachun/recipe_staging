#!/bin/bash

export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
rm -rf inst/extdata/sample_data
R CMD INSTALL --build --clean . ${R_ARGS}
