#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies progressbar-${PKG_VERSION}.gem
gem unpack progressbar-${PKG_VERSION}.gem
