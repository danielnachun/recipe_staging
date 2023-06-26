#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies ronn-${PKG_VERSION}.gem --bindir=${PREFIX}/bin
gem unpack ronn-${PKG_VERSION}.gem

mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/share/man/man7
ln -sf ${PREFIX}/share/rubygems/gems/ronn-${PKG_VERSION}/man/ronn.1 ${PREFIX}/share/man/man1
ln -sf ${PREFIX}/share/rubygems/gems/ronn-${PKG_VERSION}/man/ronn-format.7 ${PREFIX}/share/man/man7

sed -i "s?exec \"\$bindir/ruby\"?GEM_HOME=${PREFIX}/share/rubygems exec \"\$bindir/ruby\"?" ${PREFIX}/bin/ronn
