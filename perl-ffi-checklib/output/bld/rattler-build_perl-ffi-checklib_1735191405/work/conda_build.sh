#!/bin/bash
## Start of bash preamble
if [ -z ${CONDA_BUILD+x} ]; then
    source /Users/danielnachun/ghq/github.com/danielnachun/recipe_staging/perl-ffi-checklib/output/bld/rattler-build_perl-ffi-checklib_1735191405/work/build_env.sh
fi
# enable debug mode for the rest of the script
set -x
## End of preamble

perl Makefile.PL INSTALLDIRS=site
make
make test
make install
cp ${PREFIX}/man/man1/perlartistic.1 .
cp ${PREFIX}/man/man1/perlgpl.1 .