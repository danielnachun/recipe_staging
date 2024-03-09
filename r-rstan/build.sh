#!/bin/bash

# override dynamic path with known path
sed -i.bak 's|STANHEADERS_SRC =.*|STANHEADERS_SRC = $$PREFIX/lib/R/library/StanHeaders/include/src|' src/Makevars

export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
