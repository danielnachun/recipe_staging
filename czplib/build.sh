#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/lib/perl5/vendor_perl
cp *.pm ${PREFIX}/lib/perl5/vendor_perl
cp -r Microarray ${PREFIX}/lib/perl5/vendor_perl
