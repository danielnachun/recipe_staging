#!/bin/bash

export DISABLE_AUTOBREW=1

sed -i 's/crossprod/base::crossprod/' R/misc.R

# shellcheck disable=SC2086
R CMD INSTALL --build . ${R_ARGS}
