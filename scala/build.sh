#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sbt dist/packArchive

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
