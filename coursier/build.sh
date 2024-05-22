#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p .ivy2
mkdir -p .sbt
mkdir -p ${PREFIX}/bin

export GRAALVM_HOME=${PREFIX}/lib/jvm
export JAVA_HOME=${GRAALVM_HOME}
sed -i "s?--no-fallback ?--no-fallback --native-compiler-options=-L${PREFIX}/lib ?" modules/cli/src/main/resources/META-INF/native-image/io.get-coursier/coursier-cli/native-image.properties
./mill -i show cli[].nativeImage
./mill -i show cli[].publishM2Local ${SRC_DIR}/m2

install -m 755 out/cli/base-image/nativeImage.dest/cs ${PREFIX}/bin/cs
