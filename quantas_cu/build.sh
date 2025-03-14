#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
sed -i 's?/usr/bin/perl?/usr/bin/env perl?' scripts/tsu_add_splice_site_usage_CU.pl
chmod +x scripts/*.pl
cp scripts/*.pl ${PREFIX}/bin
