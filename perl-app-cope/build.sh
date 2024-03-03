#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/qw\[:all\]/qw[PATH]/' lib/App/Cope.pm
find . ./ -type f -exec bash -c "sed -i 's?/usr/bin/env perl?${PREFIX}/bin/perl?g' {}" \;

perl Makefile.PL INSTALLDIRS=site
make
#make test
make install

mkdir -p ${PREFIX}/bin
install -m 755 bin/cope_path.pl ${PREFIX}/bin/cope_path
