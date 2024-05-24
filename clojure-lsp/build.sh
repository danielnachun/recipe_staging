#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

download_licenses() {
    pom_xml=$1
    pushd $(dirname ${pom_xml})
    mvn license:download-licenses -Dgoal=download-licenses
    popd
}

export -f download_licenses

mkdir -p ${PREFIX}/bin

export GRAALVM_HOME=${PREFIX}/lib/jvm
sed -i "s?\"--native-image-info\"?\"--native-image-info\" \"--native-compiler-options=-L${PREFIX}/lib\"?" cli/build.clj
bb native-cli

find -name "pom.xml" | xargs -I % bash -c 'download_licenses %'

mkdir -p ${SRC_DIR}/target/generated-resources/licenses
find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'

install -m 755 clojure-lsp ${PREFIX}/bin
