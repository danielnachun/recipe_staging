#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PERL_CANARY_STABILITY_NOPROMPT=1

if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i 's/-arch x86_64//g' ${PREFIX}/lib/perl5/5.32/core_perl/Config_heavy.pl  
fi
perl Makefile.PL INSTALLDIRS=site NO_PERLLOCAL=1 NO_PACKLIST=1
make
make test
make install
