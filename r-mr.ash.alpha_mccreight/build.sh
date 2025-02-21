#!/bin/bash

export DISABLE_AUTOBREW=1

sed -i 's/mr.ash.alpha/mr.ash.alpha.mccreight/g' DESCRIPTION
sed -i 's/mr.ash.alpha/mr.ash.alpha.mccreight/g' NAMESPACE
sed -i 's/mr.ash.alpha/mr.ash.alpha.mccreight/g' R/RcppExports.R
sed -i 's/mr.ash.alpha/mr.ash.alpha.mccreight/g' R/mr.ash.R

# shellcheck disable=SC2086
R CMD INSTALL --build . ${R_ARGS}
