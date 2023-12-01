#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cp -R lib/* ${PREFIX}/lib/perl5/site_perl
cp -R script/* ${PREFIX}/bin
cd ${PREFIX}/bin
ls | xargs -I % sed -i "s?/usr/bin/perl -w?/usr/bin/env perl?" %
