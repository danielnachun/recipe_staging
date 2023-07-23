#!/bin/bash

export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
cd HDL
${R} CMD INSTALL --build . ${R_ARGS}
