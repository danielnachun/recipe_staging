#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

download_licenses() {
    pom_file=$1
    pom_xml=$(dirname ${pom_file})/pom.xml
    mv ${pom_file} ${pom_xml}
    sed -i 's:[\+|\-].*\-SNAPSHOT.*</version>:</version>:g' ${pom_xml}
    pushd $(dirname ${pom_xml})
    mvn license:download-licenses -Dgoal=download-licenses
    popd
}

export -f download_licenses

sbt dist/packArchive

sbt makePom

find -name "*.pom" | xargs -I % bash -c 'download_licenses %'
mkdir -p ${SRC_DIR}/target/generated-resources/licenses
find -type d -name "licenses" | grep generated-resources | grep -v "./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

mv dist/target/scala3-${PKG_VERSION}-bin-SNAPSHOT.tar.gz .
tar xzf scala3-${PKG_VERSION}-bin-SNAPSHOT.tar.gz
cp -r scala3-${PKG_VERSION}-bin-SNAPSHOT/bin ${PREFIX}/libexec/${PKG_NAME}
cp -r scala3-${PKG_VERSION}-bin-SNAPSHOT/lib ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/common << EOF
#!/bin/sh
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/common "\$@"
EOF

tee ${PREFIX}/bin/scala << EOF
#!/bin/sh
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/scala "\$@"
EOF

tee ${PREFIX}/bin/scalac << EOF
#!/bin/sh
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/scalac "\$@"
EOF

tee ${PREFIX}/bin/scaladoc << EOF
#!/bin/sh
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/scaladoc "\$@"
EOF
exit 1
