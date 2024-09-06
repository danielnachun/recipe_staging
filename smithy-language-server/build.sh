#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build with maven
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

sed -i 's/id "java"/id "java"\nid "com.github.jk1.dependency-license-report" version "latest.release"/' build.gradle

./gradlew clean build

./gradlew generateLicenseReport

install -m 644 ${SRC_DIR}/build/libs/${PKG_NAME}-${PKG_VERSION}.jar ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}.jar

# Create bash and batch files
tee ${PREFIX}/bin/smithy-language-server << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/smithy/smithy-language-server.jar "\$@"
EOF

tee ${PREFIX}/bin/smithy-language-server.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\smithy\smithy-language-server.jar %*
EOF
