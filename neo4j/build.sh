#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Build with maven
mvn clean install -DskipTests -T1C

pushd packaging/standalone/target
    tar xzf neo4j-community-${PKG_VERSION}-unix.tar.gz
    unzip -o neo4j-community-${PKG_VERSION}-windows.zip
    cp -r neo4j-community-${PKG_VERSION}/* ${PREFIX}/libexec/${PKG_NAME}
popd

ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/* ${PREFIX}/bin

mvn org.codehaus.mojo:license-maven-plugin:2.4.0:download-licenses -Dgoal=download-licenses
