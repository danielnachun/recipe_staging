#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p .ivy2
mkdir -p .sbt
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

sbt -sbt-dir $SRC_DIR/.sbt -ivy $SRC_DIR/.ivy2 "project cli" "assembly"
cp -r cli/target/scala-2.13/cli-assembly-${PKG_VERSION}.jar ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/scalariform << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec \${JAVA_HOME}/bin/java -jar "${PREFIX}/libexec/${PKG_NAME}/cli-assembly-${PKG_VERSION}.jar" "\$@"
EOF
