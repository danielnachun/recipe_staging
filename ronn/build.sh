#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies --bindir "${PREFIX}/bin" ${PKG_NAME}-${PKG_VERSION}.gem 
gem unpack ${PKG_NAME}-${PKG_VERSION}.gem

mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/share/man/man7
ln -sf ${PREFIX}/share/rubygems/gems/ronn-${PKG_VERSION}/man/ronn.1 ${PREFIX}/share/man/man1
ln -sf ${PREFIX}/share/rubygems/gems/ronn-${PKG_VERSION}/man/ronn-format.7 ${PREFIX}/share/man/man7
