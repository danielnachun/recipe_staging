#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies racc-${PKG_VERSION}.gem
gem unpack racc-${PKG_VERSION}.gem
