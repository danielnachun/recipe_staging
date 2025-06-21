#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?/usr/bin/perl?/usr/bin/env perl?" *.pl
sed -i "s/\r//" *.pl
sed -i 's/system ("perl /system ("/' *.pl

mkdir -p ${PREFIX}/bin
cp *.pl ${PREFIX}/bin
chmod +x ${PREFIX}/bin/*.pl
