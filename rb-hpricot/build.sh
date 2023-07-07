#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies hpricot-${PKG_VERSION}.gem -- --with-cflags="-Wno-incompatible-function-pointer-types" 
gem unpack hpricot-${PKG_VERSION}.gem
