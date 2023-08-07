#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export COURSIER_CACHE=${SRC_DIR}/.coursier

mkdir -p .ivy2
mkdir -p .sbt
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

./mill -i amm[3.0.0].assembly
install -m 644 out/amm/3.0.0/assembly.dest/out.jar ${PREFIX}/libexec/${PKG_NAME}/ammonite-repl.jar

tee ${PREFIX}/bin/amm << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec \${JAVA_HOME}/bin/java -jar ${PREFIX}/libexec/${PKG_NAME}/ammonite-repl.jar "\$@"
EOF
