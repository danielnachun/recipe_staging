#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

export GRAALVM_HOME=${BUILD_PREFIX}/lib/jvm
sed -i "s?\"--native-image-info\"?\"--native-image-info\" \"--native-compiler-options=-L${PREFIX}/lib\"?" cli/build.clj
bb native-cli

install -m 755 clojure-lsp ${PREFIX}/bin
