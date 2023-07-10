#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit
touch ${BUILD_PREFIX}/lib/jvm/release

./mvnw install -DskipTests=true -Dmaven.local.repo=$SRC_DIR

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
cp -r org.eclipse.jdt.ls.product/target/repository/* ${PREFIX}/libexec/${PKG_NAME}
cat << EOF > ${PREFIX}/bin/jdtls
#!/bin/sh
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/jdtls "\$@"
EOF
