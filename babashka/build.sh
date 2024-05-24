#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

export GRAALVM_HOME=${PREFIX}/lib/jvm

script/uberjar
script/compile --native-compiler-options="-L${PREFIX}/lib"

lein pom
mvn license:download-licenses -Dgoal=download-licenses

install -m 755 bb ${PREFIX}/bin
