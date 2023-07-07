#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies unicode-display_width-${PKG_VERSION}.gem
gem unpack unicode-display_width-${PKG_VERSION}.gem
