#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies --bindir "${PREFIX}/bin" debug-${PKG_VERSION}.gem
gem unpack debug-${PKG_VERSION}.gem

