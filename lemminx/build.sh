#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

export GRAALVM_HOME=${BUILD_PREFIX}/lib/jvm
sed -i "/--no-fallback/i --native-compiler-options=-L${PREFIX}/lib\n" org.eclipse.lemminx/pom.xml
./mvnw clean package -Dnative -DskipTests

if [[ ${target_platform} == "osx-64" ]]; then
    install -m 755 org.eclipse.lemminx/target/lemminx-osx-x86_64-${PKG_VERSION} ${PREFIX}/bin/lemminx
fi
if [[ ${target_platform} == "osx-arm64" ]]; then
    install -m 755 org.eclipse.lemminx/target/lemminx-osx-aarch_64-${PKG_VERSION} ${PREFIX}/bin/lemminx
fi
if [[ ${target_platform} == "linux-64" ]]; then
    install -m 755 org.eclipse.lemminx/target/lemminx-linux-x86_64-${PKG_VERSION} ${PREFIX}/bin/lemminx
fi

pushd org.eclipse.lemminx
    ../mvnw license:download-licenses -Dgoal=download-licenses
popd
mkdir -p target/generated-resources
mv org.eclipse.lemminx/target/generated-resources/licenses target/generated-resources
