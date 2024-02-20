#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PERL_MM_USE_DEFAULT=1
perl Makefile.PL INSTALLDIRS=site
make
make test
make install
