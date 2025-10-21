#!/bin/bash

export DISABLE_AUTOBREW=1

sed -i 's/-lheapt_w//g' ${PREFIX}/lib/R/etc/Makeconf

# shellcheck disable=SC2086
R CMD INSTALL --build . ${R_ARGS}
