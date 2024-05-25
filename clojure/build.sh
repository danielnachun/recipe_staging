#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

mvn -Plocal -Dmaven.test.skip=true package

mvn license:download-licenses -Dgoal=download-licenses

cp ${PKG_NAME}.jar ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/clojure << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec ${JAVA_HOME}/bin/java -jar ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}.jar "\$@"
EOF

ln -sf ${PREFIX}/bin/clojure ${PREFIX}/bin/clj
