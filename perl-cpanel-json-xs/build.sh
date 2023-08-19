#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

perl Makefile.PL INSTALLDIRS=site NO_PERLLOCAL=1 NO_PACKLIST=1
sed -i "s? ,${PREFIX}/lib??" Makefile
make
make test
make install
