#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

tar xzf GREGOR.v${PKG_VERSION}.tar.gz
cp -R GREGOR/lib/* ${PREFIX}/lib/perl5/site_perl
cp -R GREGOR/script/* ${PREFIX}/bin
cd ${PREFIX}/bin
ls | xargs -I % sed -i "s?/usr/bin/perl -w?/usr/bin/env perl?" %

sed -i 's#"\$Bin/\.\./script/"#"$Bin/"#' $PREFIX/lib/perl5/site_perl/GREGOR.pm
