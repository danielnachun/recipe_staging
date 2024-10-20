#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit
touch ${BUILD_PREFIX}/lib/jvm/release

./mvnw install -T 1 -DskipTests=true -Dmaven.local.repo=$SRC_DIR

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
cp -r org.eclipse.jdt.ls.product/target/repository/* ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/jdtls << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec ${PREFIX}/libexec/${PKG_NAME}/bin/jdtls "\$@"
EOF

./mvnw license:download-licenses -Dgoal=download-licenses
find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'
