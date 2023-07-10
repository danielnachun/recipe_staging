#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./mvnw install -DskipTests=true -Dmaven.local.repo=$SRC_DIR

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
unzip pmd-dist/target/pmd-bin-${PKG_VERSION}.zip
cp -r pmd-bin-${PKG_VERSION}/* ${PREFIX}/libexec/${PKG_NAME}

cat << EOF > ${PREFIX}/bin/pmd
JAVA_HOME=${JAVA_HOME} exec ${PREFIX}/libexec/${PKG_NAME}/bin/run.sh "\$@"
EOF
