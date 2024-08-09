#!/bin/bash

set -o errexit -o pipefail

perl Makefile.PL INSTALLDIRS=site
make
make test
make install

tee ${PREFIX}/bin/cover.cmd << EOF
call %CONDA_PREFIX%\bin\perl %CONDA_PREFIX%\bin\cover %*
EOF
