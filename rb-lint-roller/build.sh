#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies lint_roller-${PKG_VERSION}.gem
gem unpack lint_roller-${PKG_VERSION}.gem
