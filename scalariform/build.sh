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
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

sbt -sbt-dir $SRC_DIR/.sbt -ivy $SRC_DIR/.ivy2 "project cli" "assembly"
cp -r cli/target/scala-2.13/cli-assembly-${PKG_VERSION}.jar ${PREFIX}/libexec/${PKG_NAME}

sbt makePom

find -name "*.pom" | xargs -I % bash -c 'download_licenses %'
mkdir -p ${SRC_DIR}/target/generated-resources/licenses
find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'

tee ${PREFIX}/bin/scalariform << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec ${JAVA_HOME}/bin/java -jar "${PREFIX}/libexec/${PKG_NAME}/cli-assembly-${PKG_VERSION}.jar" "\$@"
EOF
