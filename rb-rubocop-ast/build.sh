#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies rubocop-ast-${PKG_VERSION}.gem
gem unpack rubocop-ast-${PKG_VERSION}.gem
