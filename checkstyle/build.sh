#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd checkstyle
mvn -e -P assembly package -DskipTests=true
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
cp target/checkstyle-${PKG_VERSION}-all.jar ${PREFIX}/libexec/${PKG_NAME}

cat << EOF > ${PREFIX}/bin/checkstyle
#!/bin/sh
exec ${JAVA_HOME}/bin/java -jar ${PREFIX}/libexec/${PKG_NAME}/checkstyle-${PKG_VERSION}-all.jar "\$@"
EOF
