#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies json-${PKG_VERSION}.gem
gem unpack json-${PKG_VERSION}.gem
