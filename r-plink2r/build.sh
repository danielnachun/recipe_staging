#!/bin/bash

export DISABLE_AUTOBREW=1
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"

# shellcheck disable=SC2086
cd plink2R
sed -i '/~~ Optionally other standard keywords, one per line, from file KEYWORDS in ~~/d' man/plink2R-package.Rd
sed -i '/~~ the R documentation directory ~~/d' man/plink2R-package.Rd
${R} CMD INSTALL --build . ${R_ARGS}
