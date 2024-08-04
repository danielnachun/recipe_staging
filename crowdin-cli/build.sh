#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Add plugin for dependency licenses
sed -i "s/id 'java'/id 'java'\nid('com.github.jk1.dependency-license-report') version 'latest.release'/" build.gradle

# Build JAR
./gradlew shadowJar

# Download dependency licenses
./gradlew generateLicenseReport

tee ${PREFIX}/bin/${PKG_NAME} << EOF
call \${CONDA_PREFIX}/bin/java -jar \${CONDA_PREFIX}/libexec/crowdin-cli.jar \$@
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %JAVA_HOME%\bin\java %PREFIX%\bin\crowdin %*
EOF
