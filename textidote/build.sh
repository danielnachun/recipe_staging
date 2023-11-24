#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

ant download-deps
ant -noinput -buildfile build.xml -Dbuild.targetjdk=19

install -m 644 textidote.jar ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec ${JAVA_HOME}/bin/java -jar "${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}.jar" "\$@"
EOF
