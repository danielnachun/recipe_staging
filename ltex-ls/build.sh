#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?<arg>-Werror<arg>??g" pom.xml

${PYTHON} -u tools/createCompletionLists.py
mvn -B -e clean compile package -DskipTests=True

tar xzf target/ltex-ls-${PKG_VERSION}.tar.gz -C .

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r ltex-ls-${PKG_VERSION}/* ${PREFIX}/libexec/${PKG_NAME}

cat << EOF > ${PREFIX}/bin/ltex-cli
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/ltex-cli "\$@"
EOF

cat << EOF > ${PREFIX}/bin/ltex-ls
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/ltex-ls "\$@"
EOF
