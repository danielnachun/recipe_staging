#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies ast-${PKG_VERSION}.gem
gem unpack ast-${PKG_VERSION}.gem
