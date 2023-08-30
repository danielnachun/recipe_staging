#!/bin/bash

export DISABLE_AUTOBREW=1

#sed -i 's/$(FLIBS)//g' src/Makevars
# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
