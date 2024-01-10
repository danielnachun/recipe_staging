#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}/bin
gem build ${PKG_NAME}.gemspec
gem install -N -l -V --ignore-dependencies --bindir "${PREFIX}/bin" ${PKG_NAME}-${PKG_VERSION}.gem
