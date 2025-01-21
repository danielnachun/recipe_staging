#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Add dependency-license-report as a plugin to build.gradle.kts

sed -i "s/id 'org.jetbrains.kotlin.jvm' version \"\$kotlinVersion\"/id 'org.jetbrains.kotlin.jvm' version \"\$kotlinVersion\"\nid(\"com.github.jk1.dependency-license-report\") version \"latest.release\"/" build.gradle

# Build with gradle
# ignore irrelevant error about missing signature for pushing artifacts to a repository - we are only building a JAR
./gradlew :adapter:installDist
./gradlew generateLicenseReport

mkdir -p ${PREFIX}/libexec/kotlin-debug-adapter
cp -r adapter/build/install/adapter/* ${PREFIX}/libexec/kotlin-debug-adapter

ln -sf ${PREFIX}/libexec/kotlin-debug-adapter/bin/kotlin-debug-adapter ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/kotlin-debug-adapter/bin/kotlin-debug-adapter.bat ${PREFIX}/bin
