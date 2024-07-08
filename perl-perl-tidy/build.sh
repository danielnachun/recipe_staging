#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

perl Makefile.PL INSTALLDIRS=site NO_PERLLOCAL=1 NO_PACKLIST=1
make
make test
make install

tee ${PREFIX}/bin/perltidy.cmd << EOF
call %CONDA_PREFIX%\bin\perl %CONDA_PREFIX%\bin\perltidy %*
EOF
