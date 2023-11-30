#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?<arg>-Werror<arg>??g" pom.xml

${PYTHON} -u tools/createCompletionLists.py
mvn -B -e clean compile package -DskipTests=True

tar xzf target/ltex-ls-${PKG_VERSION}.tar.gz -C .

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r ltex-ls-${PKG_VERSION}/* ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/ltex-cli << EOF
JAVA_HOME=${JAVA_HOME} exec ${PREFIX}/libexec/${PKG_NAME}/bin/ltex-cli "\$@"
EOF

tee ${PREFIX}/bin/ltex-ls << EOF
JAVA_HOME=${JAVA_HOME} exec ${PREFIX}/libexec/${PKG_NAME}/bin/ltex-ls "\$@"
EOF
