#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

export GRAALVM_HOME=${BUILD_PREFIX}/lib/jvm
bb native-cli

install -m 755 clojure-lsp ${PREFIX}/bin
