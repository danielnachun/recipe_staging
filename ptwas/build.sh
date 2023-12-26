#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?/usr/bin/perl?/usr/bin/env perl?g" PTWAS_est/PTWAS_est
sed -i "s?/usr/bin/Rscript?/usr/bin/env Rscript?g" PTWAS_scan/make_GAMBIT_DB.R
sed -i "s/\r//g" PTWAS_scan/make_GAMBIT_DB.R

mkdir -p ${PREFIX}/bin
install -m 755 PTWAS_est/PTWAS_est ${PREFIX}/bin
install -m 755 PTWAS_scan/make_GAMBIT_DB.R ${PREFIX}/bin
