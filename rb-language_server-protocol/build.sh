#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies language_server-protocol-${PKG_VERSION}.gem
gem unpack language_server-protocol-${PKG_VERSION}.gem
