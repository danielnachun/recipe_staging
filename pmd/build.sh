#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./mvnw install -DskipTests=true -Dmaven.local.repo=$SRC_DIR

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
unzip pmd-dist/target/pmd-dist-7.2.0-SNAPSHOT-bin.zip
cp -r pmd-bin-7.2.0-SNAPSHOT/* ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/pmd << EOF
JAVA_HOME=${JAVA_HOME} exec ${PREFIX}/libexec/${PKG_NAME}/bin/pmd "\$@"
EOF

./mvnw license:download-licenses -Dgoal=download-licenses
