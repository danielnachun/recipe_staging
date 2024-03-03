#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/qw\[:all\]/qw[PATH]/' lib/App/Cope.pm

perl Makefile.PL INSTALLDIRS=site
make
make test
make install

mkdir -p ${PREFIX}/bin
install -Dm 755 bin/cope_path.pl ${PREFIX}/bin/cope_path
