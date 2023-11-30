#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd checkstyle
mvn -e -P assembly package -DskipTests=true
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
cp target/checkstyle-${PKG_VERSION}-all.jar ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/checkstyle << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec ${JAVA_HOME}/bin/java -jar ${PREFIX}/libexec/${PKG_NAME}/checkstyle-${PKG_VERSION}-all.jar "\$@"
EOF
