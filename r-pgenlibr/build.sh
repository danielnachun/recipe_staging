#!/bin/bash

export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
cd 2.0/pgenlibr
${R} CMD INSTALL --build . ${R_ARGS}
