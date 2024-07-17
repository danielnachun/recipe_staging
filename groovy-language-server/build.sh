#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/id "java"/id "java"\nid("com.github.jk1.dependency-license-report") version "latest.release"/' build.gradle

./gradlew build
./gradlew generateLicenseReport

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
install -m 644 build/libs/work-all.jar ${PREFIX}/libexec/${PKG_NAME}/groovy-language-server-all.jar

tee ${PREFIX}/bin/groovy-language-server << EOF
#!/bin/sh
export JAVA_HOME=${JAVA_HOME}
exec ${JAVA_HOME}/bin/java -jar ${PREFIX}/libexec/${PKG_NAME}/groovy-language-server-all.jar "\$@"
EOF
