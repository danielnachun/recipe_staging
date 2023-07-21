#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?/usr/bin/?${PREFIX}/bin/?g" PTWAS_est/PTWAS_est
sed -i "s?/usr/bin/?${PREFIX}/bin/?g" PTWAS_scan/make_GAMBIT_DB.R

mkdir -p ${PREFIX}/bin
install -m 755 PTWAS_est/PTWAS_est ${PREFIX}/bin
install -m 755 PTWAS_scan/make_GAMBIT_DB.R ${PREFIX}/bin
