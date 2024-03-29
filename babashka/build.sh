#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

export GRAALVM_HOME=${BUILD_PREFIX}/lib/jvm

script/uberjar
script/compile --native-compiler-options="-L${PREFIX}/lib"

install -m 755 bb ${PREFIX}/bin
