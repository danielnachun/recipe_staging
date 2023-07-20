#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit
LD=$CC
rm t/19_handle.t

perl Makefile.PL INSTALLDIRS=site NO_PERLLOCAL=1 NO_PACKLIST=1
make
make test
make install
