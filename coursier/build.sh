#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

download_licenses() {
    pom_file=$1
    pom_xml=$(dirname ${pom_file})/pom.xml
    mv ${pom_file} ${pom_xml}
    pushd $(dirname ${pom_xml})
    mvn license:download-licenses -Dgoal=download-licenses
    popd
}

export -f download_licenses

mkdir -p .ivy2
mkdir -p .sbt
mkdir -p ${PREFIX}/bin

export GRAALVM_HOME=${PREFIX}/lib/jvm
export JAVA_HOME=${GRAALVM_HOME}
sed -i "s?--no-fallback ?--no-fallback --native-compiler-options=-L${PREFIX}/lib ?" modules/cli/src/main/resources/META-INF/native-image/io.get-coursier/coursier-cli/native-image.properties
./mill -i show cli[].nativeImage
./mill -i show cli[].publishM2Local ${SRC_DIR}/m2

find m2 -name "*.pom" | xargs -I % bash -c 'download_licenses %'
mkdir -p ${SRC_DIR}/target/generated-resources/licenses
find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'

install -m 755 out/cli/**/base-image/nativeImage.dest/cs ${PREFIX}/bin/cs
