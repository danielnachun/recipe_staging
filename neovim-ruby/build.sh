#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies --bindir "${PREFIX}/bin" neovim-${PKG_VERSION}.gem
gem unpack neovim-${PKG_VERSION}.gem
