#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?<arg>-Werror<arg>??g" pom.xml

${PYTHON} -u tools/createCompletionLists.py
mvn -B -e clean compile package -DskipTests=True

tar xzf target/ltex-ls-${PKG_VERSION}.tar.gz -C .

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r ltex-ls-${PKG_VERSION}/* ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/ltex-cli ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/ltex-ls ${PREFIX}/bin
