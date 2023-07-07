#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies mustache-${PKG_VERSION}.gem
gem unpack mustache-${PKG_VERSION}.gem
