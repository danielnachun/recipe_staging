#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

sed -i "s?/usr/bin/env perl?${PREFIX}/bin/perl?" _countit/*.pl
sed -i "s?/usr/bin/env perl?${PREFIX}/bin/perl?" _gapless/*.pl

cp _countit/*.pl ${PREFIX}/bin
cp _gapless/*.pl ${PREFIX}/bin
