#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies rdiscount-${PKG_VERSION}.gem
gem unpack rdiscount-${PKG_VERSION}.gem
