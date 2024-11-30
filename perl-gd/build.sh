#!/bin/bash

# Make sure this goes in site
perl Makefile.PL INSTALLDIRS=site
make
make test
make install

chmod u+w $PREFIX/bin/bdf2gdfont.pl
chmod u+w $PREFIX/bin/bdftogd

pod2text ${PREFIX}/lib/perl5/core_perl/pods/perlartistic.pod > LICENSE-ARTISTIC
