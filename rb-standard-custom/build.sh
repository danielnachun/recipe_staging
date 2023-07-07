#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies standard-custom-${PKG_VERSION}.gem
gem unpack standard-custom-${PKG_VERSION}.gem
