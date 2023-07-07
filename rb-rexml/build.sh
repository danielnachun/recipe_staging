#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies rexml-${PKG_VERSION}.gem
gem unpack rexml-${PKG_VERSION}.gem
