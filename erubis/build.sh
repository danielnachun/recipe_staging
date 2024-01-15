#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --bindir "${PREFIX}/bin" --ignore-dependencies ${PKG_NAME}-${PKG_VERSION}.gem
gem unpack ${PKG_NAME}-${PKG_VERSION}.gem
