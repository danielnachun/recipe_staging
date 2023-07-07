#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies rubcop-performance-${PKG_VERSION}.gem
gem unpack rubcop-performance-${PKG_VERSION}.gem
