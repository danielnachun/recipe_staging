#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir release
mvn install -DskipTests=true -Dmaven.repo.local=${SRC_DIR}

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

cp com/google/googlejavaformat/google-java-format/${PKG_VERSION}/google-java-format-${PKG_VERSION}-all-deps.jar ${PREFIX}/libexec/${PKG_NAME}
tee ${PREFIX}/bin/google-java-format << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec ${JAVA_HOME}/bin/java -jar ${PREFIX}/libexec/${PKG_NAME}/google-java-format-${PKG_VERSION}-all-deps.jar "\$@"
EOF

install -m 755 scripts/google-java-format-diff.py ${PREFIX}/bin/google-java-format-diff
