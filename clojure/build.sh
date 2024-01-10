#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

sed -i "s?\${HOMEBREW_RUBY_PATH}?${BUILD_PREFIX}/bin/ruby?g" install.sh
sed -i "s?libexec?libexec/${PKG_NAME}?g" install.sh
sed -i "s?libexec?libexec/${PKG_NAME}?g" clojure
./install.sh ${PREFIX}
