#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

ant jar
cp build/artifact/jars/ivy.jar ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/ivy << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec \${JAVA_HOME}/bin/java -jar "${PREFIX}/libexec/${PKG_NAME}/ivy.jar" "\$@"
EOF
