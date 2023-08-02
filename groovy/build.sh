#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./gradlew clean dist
mv subprojects/groovy-binary/build/distributions/apache-groovy-binary-${PKG_VERSION}.zip .
unzip apache-groovy-binary-${PKG_VERSION}.zip

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
cp -r groovy-${PKG_VERSION}/* ${PREFIX}/libexec/${PKG_NAME}

env_script() {
bin_name=$(basename $1)
tee ${PREFIX}/bin/${bin_name} << EOF
#!/bin/sh
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/${bin_name} "\$@"
EOF
}

export -f env_script

find ${PREFIX}/libexec/${PKG_NAME}/bin -type f | grep -v ".bat" | grep -v ".ico" | sort -u | xargs --replace=% bash -c "env_script %"
