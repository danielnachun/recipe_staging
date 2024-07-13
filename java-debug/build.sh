#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./mvnw clean install

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

cp -r com.microsoft.java.debug.plugin/lib/*.jar ${PREFIX}/libexec/${PKG_NAME}
cp -r com.microsoft.java.debug.plugin/target/*.jar ${PREFIX}/libexec/${PKG_NAME}

./mvnw license:download-licenses -Dgoal=download-licenses
cp ${SRC_DIR}/com.microsoft.java.debug.core/target/generated-resources/licenses/* ${SRC_DIR}/target/generated-resources/licenses
cp ${SRC_DIR}/com.microsoft.java.debug.plugin/target/generated-resources/licenses/* ${SRC_DIR}/target/generated-resources/licenses
