#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p .ivy2
mkdir -p .sbt
mkdir -p ${PREFIX}/bin

export GRAALVM_HOME=${PREFIX}/lib/jvm
export JAVA_HOME=${GRAALVM_HOME}
sed -i "s/--initialize-at-build-time /--initialize-at-build-time --diagnostics-mode --native-compiler-options=-L\${PREFIX}\/lib --initialize-at-run-time=org.scalafmt.cli.ScalafmtDynamicRunner$ /" scalafmt-cli/src/main/resources/META-INF/native-image/org.scalafmt/scalafmt-cli/native-image.properties
sed -i "s/version=.*$/version=${PKG_VERSION}-SNAPSHOT/" .scalafmt.conf
sbt -sbt-dir $SRC_DIR/.sbt -ivy $SRC_DIR/.ivy2 native-image

install -m 755 scalafmt-cli/target/native-image/cli ${PREFIX}/bin/scalafmt
