#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

download_licenses() {
    pom_file=$1
    pom_xml=$(dirname ${pom_file})/pom.xml
    mv ${pom_file} ${pom_xml}
    sed -i 's:\-SNAPSHOT</version>:</version>:g' ${pom_xml}
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
sed -i "s/--initialize-at-build-time /--initialize-at-build-time --diagnostics-mode --native-compiler-options=-L\${PREFIX}\/lib --initialize-at-run-time=org.scalafmt.cli.ScalafmtDynamicRunner$ /" scalafmt-cli/src/main/resources/META-INF/native-image/org.scalafmt/scalafmt-cli/native-image.properties
sed -i "s/version=.*$/version=${PKG_VERSION}-SNAPSHOT/" .scalafmt.conf
sbt -sbt-dir $SRC_DIR/.sbt -ivy $SRC_DIR/.ivy2 native-image

sbt makePom

find -name "*.pom" | xargs -I % bash -c 'download_licenses %'
mkdir -p ${SRC_DIR}/target/generated-resources/licenses
find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'

install -m 755 scalafmt-cli/target/native-image/cli ${PREFIX}/bin/scalafmt
