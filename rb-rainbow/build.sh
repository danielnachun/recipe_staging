#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies rainbow-${PKG_VERSION}.gem
gem unpack rainbow-${PKG_VERSION}.gem
